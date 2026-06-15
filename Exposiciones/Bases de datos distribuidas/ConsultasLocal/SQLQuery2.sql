

USE BDDistribuida_CR;
GO

/* ============================================================
   PRUEBA 1: CONSULTA LOCAL
   Muestra los clientes que están guardados en la computadora.
   Esto representa la sede de Costa Rica.
   ============================================================ */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM ClientesCR;
GO


/* ============================================================
   PRUEBA 2: CONSULTA REMOTA
   Muestra los clientes que están guardados en la máquina virtual.
   Esto representa la sede de México.
   ============================================================ */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX;
GO


/* ============================================================
   PRUEBA 3: BASE DE DATOS DISTRIBUIDA
   Une datos de dos bases que están en lugares diferentes.
   Una está en la computadora y otra en la máquina virtual.
   ============================================================ */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Computadora principal - Costa Rica' AS Ubicacion
FROM ClientesCR

UNION ALL

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Máquina virtual - México' AS Ubicacion
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX;
GO


/* ============================================================
   PRUEBA 4: FRAGMENTACIÓN HORIZONTAL
   Los datos se dividen por filas.
   Costa Rica tiene sus clientes y México tiene los suyos.
   ============================================================ */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM ClientesCR

UNION ALL

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX;
GO


/* ============================================================
   PRUEBA 5: FRAGMENTACIÓN VERTICAL
   Los datos de un mismo cliente están separados por columnas.
   En la computadora están los datos básicos.
   En la VM están los datos de contacto.
   ============================================================ */


SELECT 
    B.IdCliente,
    B.Nombre,
    B.Cedula,
    B.Pais,
    C.Telefono,
    C.Correo,
    C.Direccion
FROM DatosBasicosClientes B
INNER JOIN [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ContactoClientes C
    ON B.IdCliente = C.IdCliente;
GO


/* ============================================================
   PRUEBA 6: FRAGMENTACIÓN MIXTA
   Combina fragmentación horizontal y vertical.
   Horizontal: clientes separados por país.
   Vertical: datos básicos y datos de contacto separados.
   ============================================================ */
SELECT 
    B.IdCliente,
    B.Nombre,
    B.Cedula,
    B.Pais,
    'Costa Rica' AS Sede,
    C.Telefono,
    C.Correo,
    C.Direccion,
    'Horizontal por sede y vertical por datos del cliente' AS TipoFragmentacion
FROM DatosBasicosClientes B
INNER JOIN [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ContactoClientes C
    ON B.IdCliente = C.IdCliente

UNION ALL

SELECT 
    M.IdCliente,
    M.Nombre,
    'No aplica' AS Cedula,
    M.Pais,
    'México' AS Sede,
    'No disponible' AS Telefono,
    'No disponible' AS Correo,
    'No disponible' AS Direccion,
    'Cliente ubicado en la sede México' AS TipoFragmentacion
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX M;
GO


/* ============================================================
   PRUEBA 7: REPORTE DISTRIBUIDO DE VENTAS
   Une las ventas de Costa Rica y México en una sola consulta.
   ============================================================ */

SELECT 
    IdVenta,
    IdCliente,
    Producto,
    Monto,
    Fecha,
    'Costa Rica' AS Sede
FROM VentasCR

UNION ALL

SELECT 
    IdVenta,
    IdCliente,
    Producto,
    Monto,
    Fecha,
    'México' AS Sede
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.VentasMX;
GO


/* ============================================================
   PRUEBA 8: TOTAL DE VENTAS POR SEDE
   Calcula cuánto vendió cada sede.
   ============================================================ */


SELECT 
    'Costa Rica' AS Sede,
    SUM(Monto) AS TotalVentas
FROM VentasCR

UNION ALL

SELECT 
    'México' AS Sede,
    SUM(Monto) AS TotalVentas
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.VentasMX;
GO


/* ============================================================
   PRUEBA 9: TOTAL GENERAL DE VENTAS
   Calcula el total de ventas de toda la empresa.
   Aunque los datos estén en dos bases diferentes.
   ============================================================ */

SELECT 
    SUM(Monto) AS TotalGeneralVentas
FROM (
    SELECT Monto 
    FROM VentasCR

    UNION ALL

    SELECT Monto 
    FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.VentasMX
) AS TodasLasVentas;
GO


/* ============================================================
   PRUEBA 10: REPLICACIÓN DE DATOS
   La tabla ProductosReplicados existe en ambas bases.
   Esto representa que hay copia de datos en más de un lugar.
   ============================================================ */

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Computadora principal' AS Ubicacion
FROM ProductosReplicados

UNION ALL

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Máquina virtual' AS Ubicacion
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ProductosReplicados;
GO


/* ============================================================
   PRUEBA 11: PROBLEMA DE CONSISTENCIA
   Cambiamos el precio solo en la computadora.
   Luego comparamos con la máquina virtual.
   ============================================================ */

UPDATE ProductosReplicados
SET Precio = 70000
WHERE IdProducto = 1;
GO

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Computadora principal' AS Ubicacion
FROM ProductosReplicados

UNION ALL

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Máquina virtual' AS Ubicacion
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ProductosReplicados;
GO


/* ============================================================
   PRUEBA 12: DETECTAR INCONSISTENCIAS
   Compara el precio local contra el precio remoto.
   Si son diferentes, marca Inconsistente.
   ============================================================ */

SELECT 
    L.IdProducto,
    L.NombreProducto,
    L.Precio AS PrecioLocal,
    R.Precio AS PrecioRemoto,
    CASE 
        WHEN L.Precio = R.Precio THEN 'Consistente'
        ELSE 'Inconsistente'
    END AS EstadoDato
FROM ProductosReplicados L
INNER JOIN [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ProductosReplicados R
    ON L.IdProducto = R.IdProducto;
GO


/* ============================================================
   PRUEBA 13: SINCRONIZACIÓN
   Actualizamos también el dato en la máquina virtual.
   Así las dos bases vuelven a quedar iguales.
   ============================================================ */

UPDATE [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ProductosReplicados
SET Precio = 70000
WHERE IdProducto = 1;
GO

SELECT 
    L.IdProducto,
    L.NombreProducto,
    L.Precio AS PrecioLocal,
    R.Precio AS PrecioRemoto,
    CASE 
        WHEN L.Precio = R.Precio THEN 'Consistente'
        ELSE 'Inconsistente'
    END AS EstadoDato
FROM ProductosReplicados L
INNER JOIN [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ProductosReplicados R
    ON L.IdProducto = R.IdProducto;
GO


/* ============================================================
   PRUEBA 14: TRANSPARENCIA DE UBICACIÓN
   Desde una sola consulta se ven datos locales y remotos.
   El usuario no trabaja directamente en cada servidor.
   ============================================================ */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Dato local' AS TipoUbicacion
FROM ClientesCR

UNION ALL

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Dato remoto' AS TipoUbicacion
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX;
GO


/* ============================================================
   PRUEBA 15: AUTONOMÍA LOCAL
   La sede de Costa Rica puede trabajar con sus propios datos
   sin depender de la otra sede.
   ============================================================ */

SELECT 
    C.IdCliente,
    C.Nombre,
    C.Pais,
    C.Ciudad,
    V.Producto,
    V.Monto,
    V.Fecha
FROM ClientesCR C
INNER JOIN VentasCR V
    ON C.IdCliente = V.IdCliente;
GO



/* ============================================================
   PRUEBA 16: RESUMEN FINAL DE CLIENTES Y VENTAS
   Muestra clientes y ventas de ambas sedes en una sola consulta.
   ============================================================ */

SELECT 
    C.IdCliente,
    C.Nombre,
    C.Pais,
    C.Ciudad,
    V.Producto,
    V.Monto,
    V.Fecha,
    'Costa Rica' AS Sede
FROM ClientesCR C
INNER JOIN VentasCR V
    ON C.IdCliente = V.IdCliente

UNION ALL

SELECT 
    C.IdCliente,
    C.Nombre,
    C.Pais,
    C.Ciudad,
    V.Producto,
    V.Monto,
    V.Fecha,
    'México' AS Sede
FROM [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.ClientesMX C
INNER JOIN [DESKTOP-S995E00\SQLEXPRESS].BDDistribuida_MX.dbo.VentasMX V
    ON C.IdCliente = V.IdCliente;
GO


/* ============================================================
   FIN DE LAS PRUEBAS
   ============================================================ */