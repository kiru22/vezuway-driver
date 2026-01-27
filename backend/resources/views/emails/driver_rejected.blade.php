<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actualización de solicitud</title>
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
            background-color: #dc2626;
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
        .reason-box {
            background-color: #fee2e2;
            border-left: 4px solid #dc2626;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
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
        <h1>Actualización sobre tu solicitud</h1>
    </div>
    <div class="content">
        <p>Hola {{ $driver->name }},</p>

        <p>Lamentamos informarte que tu solicitud para ser conductor en vezuway no ha sido aprobada en este momento.</p>

        @if($reason)
        <div class="reason-box">
            <strong>Motivo:</strong><br>
            {{ $reason }}
        </div>
        @endif

        <p>Si crees que se trata de un error o deseas obtener más información sobre esta decisión, por favor contáctanos respondiendo a este email.</p>

        <p>Gracias por tu interés en vezuway.</p>
    </div>
    <div class="footer">
        <p>&copy; {{ date('Y') }} vezuway. Todos los derechos reservados.</p>
    </div>
</body>
</html>
