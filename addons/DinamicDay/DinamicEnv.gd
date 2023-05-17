tool
extends WorldEnvironment

# Define si es de dia o de noche
export (bool) var day = true
export (NodePath) var light 
# Colores definidos para dia y tarde
export (Color) var top_color_day = Color(0.231373, 0.572549, 0.756863)
export (Color) var top_color_evening = Color(0.007843, 0.301961, 0.462745)
export (Color) var horizon_color_day = Color(0.615686, 0.760784, 0.87451)
export (Color) var horizon_color_evening = Color(0.992157, 0.541176, 0.137255)
export (Color) var sun_color_day = Color(0.964706, 0.917647, 0.537255)
export (Color) var sun_color_evening = Color(0.92549, 0.305882, 0)
#export var sky_curve_day := 0.09
#export var sky_curve_evening := 0.12
export (Color) var top_color_night = Color(0, 0.090196, 0.141176)
export (Color) var horizon_color_night = Color(0.07451, 0.184314, 0.270588)
export (Color) var sun_color_night = Color(0.576471, 0.576471, 0.576471)

    

func _process(delta):
    var sky = get_environment().get_sky()
    var l = get_node(light)
    if l is DirectionalLight and sky is ProceduralSky:
        # Alineando sol procedural y luz direccional
        var ang_light = l.get_rotation_degrees()
        ang_light[1] = ang_light[1] * (-1)
        ang_light[0] = ang_light[0] * (-1)
        ang_light[1] = ang_light[1] - 180
        
        sky.set_sun_latitude(ang_light[0])
        sky.set_sun_longitude(ang_light[1])
    
        # Ajustando colores conforme a hora del día
        # interpolando el color de atardecer con el del dia
        if day:
            var h = sky.get_sun_latitude()
            # Asegurando valores positivos
            if h < 0:
                h = h * (-1)
            if h > 90:
                h = 180 - h
            h = (h / 46)
            if h > 1:
                h = 1
            sky.set_sky_top_color(
                top_color_evening.linear_interpolate(top_color_day, h)
            )
            sky.set_sky_horizon_color(
                horizon_color_evening.linear_interpolate(horizon_color_day, h)
            )
            sky.set_sun_color(
                sun_color_evening.linear_interpolate(sun_color_day, h)
            )
            sky.set_sun_angle_min(1)
            sky.set_sun_angle_max(100)
            sky.set_sun_curve(0.05)
        else:
            sky.set_sky_top_color(top_color_night)
            sky.set_sky_horizon_color(horizon_color_night)
            sky.set_sun_color(sun_color_night)
            sky.set_sun_angle_min(2)  
            sky.set_sun_angle_max(28)
            sky.set_sun_curve(0.0196)
        
        # Ajustando la luz direccional al color del sol
        l.light_color = sky.get_sun_color()
