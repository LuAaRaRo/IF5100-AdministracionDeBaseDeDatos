CREATE TRIGGER TR_INSERT_CLIENTES
ON CLIENTES 
AFTER INSERT
AS 
BEGIN 
	INSERT INTO [dbo].[BITACORA_EVENTOS]
           ([NOMBRE_EVENTO]
           ,[DESCRIPCION]
           ,[TABLA]
           ,[FECHA_EVENTO]
           ,[DATOS_POSTERIORES]
           ,[DATOS_ANTERIORES])
     VALUES
           ('INSERT'
           ,'INSERTANDO DATOS'
           ,'CLIENTES'
           ,GETDATE()
         ,''
             , (      SELECT *
					FROM inserted
					FOR JSON PATH
					))
END