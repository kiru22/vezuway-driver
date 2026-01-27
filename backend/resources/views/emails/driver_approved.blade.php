<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cuenta aprobada</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #10B981;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 8px 8px 0 0;
        }
        .content {
            background-color: #f9f9f9;
            padding: 30px;
            border-radius: 0 0 8px 8px;
        }
        .button {
            display: inline-block;
            background-color: #10B981;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 20px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎉 ¡Felicidades, {{ $driver->name }}!</h1>
    </div>
    <div class="content">
        <p>Tenemos excelentes noticias para ti.</p>

        <p><strong>Tu cuenta de conductor en vezuway ha sido aprobada.</strong></p>

        <p>Ahora puedes:</p>
        <ul>
            <li>Crear y gestionar rutas de transporte</li>
            <li>Aceptar pedidos de clientes</li>
            <li>Organizar tus viajes entre Ucrania y España</li>
            <li>Administrar tus contactos de envío</li>
        </ul>

        <p>Para empezar, simplemente inicia sesión en la aplicación.</p>

        <center>
            <a href="{{ config('app.frontend_url') }}" class="button">Ir a vezuway</a>
        </center>

        <p style="margin-top: 30px;">Si tienes alguna pregunta, no dudes en contactarnos.</p>

        <p>¡Bienvenido a la familia vezuway! 🚚</p>
    </div>
    <div class="footer">
        <p>&copy; {{ date('Y') }} vezuway. Todos los derechos reservados.</p>
    </div>
</body>
</html>
