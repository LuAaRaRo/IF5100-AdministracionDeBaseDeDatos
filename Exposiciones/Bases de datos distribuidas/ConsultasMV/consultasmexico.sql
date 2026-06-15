
USE BDDistribuida_MX;
GO

/* =====================================================
   PRUEBA 1: CONSULTA LOCAL EN LA MÁQUINA VIRTUAL
   Aquí se ven los clientes guardados en la VM.
   Esto representa la sede México.
   ===================================================== */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Máquina virtual - México' AS Ubicacion
FROM ClientesMX;
GO


/* =====================================================
   PRUEBA 2: CONSULTA REMOTA HACIA LA COMPUTADORA
   Aquí la VM consulta la base de datos que está en tu PC.
   Esto representa la sede Costa Rica.
   ===================================================== */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Computadora principal - Costa Rica' AS Ubicacion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ClientesCR;
GO


/* =====================================================
   PRUEBA 3: CONSULTA DISTRIBUIDA DE CLIENTES
   Une clientes de México y Costa Rica en una sola consulta.
   ===================================================== */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Máquina virtual - México' AS Ubicacion
FROM ClientesMX

UNION ALL

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad,
    'Computadora principal - Costa Rica' AS Ubicacion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ClientesCR;
GO


/* =====================================================
   PRUEBA 4: FRAGMENTACIÓN HORIZONTAL
   Los datos están separados por filas.
   México está en la VM y Costa Rica está en la computadora.
   ===================================================== */

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM ClientesMX

UNION ALL

SELECT 
    IdCliente,
    Nombre,
    Pais,
    Ciudad
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ClientesCR;
GO


/* =====================================================
   PRUEBA 5: FRAGMENTACIÓN VERTICAL
   Los datos de un cliente están divididos por columnas.
   Datos básicos en la PC y datos de contacto en la VM.
   ===================================================== */

SELECT 
    B.IdCliente,
    B.Nombre,
    B.Cedula,
    B.Pais,
    C.Telefono,
    C.Correo,
    C.Direccion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.DatosBasicosClientes B
INNER JOIN ContactoClientes C
    ON B.IdCliente = C.IdCliente;
GO


/* =====================================================
   PRUEBA 6: FRAGMENTACIÓN MIXTA
   Combina fragmentación horizontal y vertical.
   Horizontal: clientes separados por sede.
   Vertical: datos básicos y contacto separados.
   ===================================================== */

SELECT 
    B.IdCliente,
    B.Nombre,
    B.Cedula,
    B.Pais,
    'Costa Rica' AS Sede,
    C.Telefono,
    C.Correo,
    C.Direccion,
    'Fragmentación mixta: datos por sede y por columnas' AS Explicacion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.DatosBasicosClientes B
INNER JOIN ContactoClientes C
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
    'Cliente completo guardado en la VM' AS Explicacion
FROM ClientesMX M;
GO


/* =====================================================
   PRUEBA 7: REPORTE DISTRIBUIDO DE VENTAS
   Une las ventas de México y Costa Rica.
   ===================================================== */

SELECT 
    IdVenta,
    IdCliente,
    Producto,
    Monto,
    Fecha,
    'México' AS Sede
FROM VentasMX

UNION ALL

SELECT 
    IdVenta,
    IdCliente,
    Producto,
    Monto,
    Fecha,
    'Costa Rica' AS Sede
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.VentasCR;
GO


/* =====================================================
   PRUEBA 8: TOTAL DE VENTAS POR SEDE
   Compara cuánto vendió cada sede.
   ===================================================== */

SELECT 
    'México' AS Sede,
    SUM(Monto) AS TotalVentas
FROM VentasMX

UNION ALL

SELECT 
    'Costa Rica' AS Sede,
    SUM(Monto) AS TotalVentas
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.VentasCR;
GO


/* =====================================================
   PRUEBA 9: TOTAL GENERAL DE VENTAS
   Suma las ventas de ambas bases de datos.
   ===================================================== */

SELECT 
    SUM(Monto) AS TotalGeneralVentas
FROM (
    SELECT Monto 
    FROM VentasMX

    UNION ALL

    SELECT Monto 
    FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.VentasCR
) AS TodasLasVentas;
GO


/* =====================================================
   PRUEBA 10: REPLICACIÓN DE DATOS
   La tabla ProductosReplicados existe en la VM y en la PC.
   ===================================================== */

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Máquina virtual' AS Ubicacion
FROM ProductosReplicados

UNION ALL

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Computadora principal' AS Ubicacion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ProductosReplicados;
GO


/* =====================================================
   PRUEBA 11: PROBLEMA DE CONSISTENCIA
   Cambiamos el precio solo en la VM.
   Luego se compara con la PC.
   ===================================================== */

UPDATE ProductosReplicados
SET Precio = 480000
WHERE IdProducto = 1;
GO

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Máquina virtual' AS Ubicacion
FROM ProductosReplicados

UNION ALL

SELECT 
    IdProducto,
    NombreProducto,
    Precio,
    'Computadora principal' AS Ubicacion
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ProductosReplicados;
GO


/* =====================================================
   PRUEBA 12: DETECTAR INCONSISTENCIAS
   Compara el precio del producto en la VM y en la PC.
   ===================================================== */

SELECT 
    M.IdProducto,
    M.NombreProducto,
    M.Precio AS PrecioVM,
    P.Precio AS PrecioPC,
    CASE 
        WHEN M.Precio = P.Precio THEN 'Consistente'
        ELSE 'Inconsistente'
    END AS EstadoDato
FROM ProductosReplicados M
INNER JOIN [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ProductosReplicados P
    ON M.IdProducto = P.IdProducto;
GO


/* =====================================================
   PRUEBA 13: SINCRONIZACIÓN
   Actualiza el precio también en la computadora.
   Así ambas bases vuelven a quedar iguales.
   ===================================================== */

UPDATE [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ProductosReplicados
SET Precio = 480000
WHERE IdProducto = 1;
GO

SELECT 
    M.IdProducto,
    M.NombreProducto,
    M.Precio AS PrecioVM,
    P.Precio AS PrecioPC,
    CASE 
        WHEN M.Precio = P.Precio THEN 'Consistente'
        ELSE 'Inconsistente'
    END AS EstadoDato
FROM ProductosReplicados M
INNER JOIN [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ProductosReplicados P
    ON M.IdProducto = P.IdProducto;
GO


/* =====================================================
   PRUEBA 14: AUTONOMÍA LOCAL
   La VM puede trabajar con sus propios datos sin depender
   de la computadora principal.
   ===================================================== */

SELECT 
    C.IdCliente,
    C.Nombre,
    C.Pais,
    C.Ciudad,
    V.Producto,
    V.Monto,
    V.Fecha
FROM ClientesMX C
INNER JOIN VentasMX V
    ON C.IdCliente = V.IdCliente;
GO


/* =====================================================
   PRUEBA 15: RESUMEN FINAL DISTRIBUIDO
   Muestra clientes y ventas de ambas sedes.
   ===================================================== */

SELECT 
    C.IdCliente,
    C.Nombre,
    C.Pais,
    C.Ciudad,
    V.Producto,
    V.Monto,
    V.Fecha,
    'México' AS Sede
FROM ClientesMX C
INNER JOIN VentasMX V
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
    'Costa Rica' AS Sede
FROM [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.ClientesCR C
INNER JOIN [DESKTOP-VCASHGS\SQLEXPRESS].BDDistribuida_CR.dbo.VentasCR V
    ON C.IdCliente = V.IdCliente;
GO