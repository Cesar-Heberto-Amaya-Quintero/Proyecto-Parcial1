# Proyecto-Parcial1
### Contenido
En el proyecto se puede encontrar un shader para el render de un personaje en 3D el cual contiene las siguientes características:
•	Contiene un color albedo par la iluminación.
•	Soporta un mapa de textura y un mapa de normales.
•	Controlar la intensidad del mapa de normal.
•	Esta basado en Lambert y se le puede agregar un efecto de Phong (el cual nos permite obtener el sombreado de la superficie).
•	Cuenta con un Phong color para cambiar de color el brillo.
•	Efecto Rim (permite emitir la luz alrededor de la superficie).
•	Cuenta con un Ramp Texture utilizando la técnica Banded.

### Herramientas
•	Unity 3D
•	Visual Studio Code usando HLSL
Desarrollo
Lo primero que necesitamos hacer para realizar el shader, es iniciar un nuevo proyecto en Unity, una vez hecho esto crearemos un nuevo shader en el cuál programaremos todo lo necesario. Para poder ver los efectos de nuestro shader necesitaremos un cuerpo en el cuál agregarle ese shader, podemos descargar un modelo 3D a nuestro gusto o bien utilizar una esfera creada en Unity.
Ahora comenzamos con nuestro shader creando su estructura donde agregamos el nombre, la sección de Properties, la sección de SubShader donde incluiremos los Tags y la sección donde codificaremos el shader con HLSL la cual se inicia con CGPROGRAM y se finaliza con ENDCG, dentro incluiremos el pragma para que trabaje en la superficie.
- Para crear el color albedo primero necesitamos decir en las propiedades que agregaremos un color el cuál lo iniciaremos en blanco, ahora necesitamos declarar esa variable en nuestro código, crearemos una función utilizando el sufijo Lighting para que sepa que es un modelo de luz, la cual contendrá un SurfaceOutput, una variable lightDir para la dirección de la luz y una variable para la atenuación para saber la intensidad del color de la luz, dentro de esta función calculamos el producto punto entre la normal y el lightDIr, lo cual es equivalente al Lambert, devolvemos nuestro Lambert multiplicado por el Albedo y la atenuación en una variable llamada c, también creamos una función llamada surf para poder devolver ese color por medio del SurfaceOutput.
- Para agregarle un fallOff y controlar la sombras del cuerpo, lo primero es crear una propiedad de tipo rango a la cual llamamos _FallOff, declararla en nuestro código, dentro de la función Lighting calculamos nuestro fallOff y se lo multiplicamos dentro de la variable c donde multiplicamos lo anterior.
-Para agregarle el efecto de Phong y darle brillo al cuerpo necesitaremos de un SpecularColor, en el cual decidiremos el color de la luz reflejada, de un SpecularPower que será de tipo rango, para controlar la intensidad de dicho reflejo, de un SpecularGloss igual de tipo rango, donde controlaremos que tanto abarcará este efecto y un GlossSteps de tipo rango, para agrandar los pasos requeridos para el efecto, necesitaremos de un viewDir para saber desde donde se ve el objeto. Luego reflejaremos el vector entre el lighDir y la normal, una vez hecho esto realizamos el producto punto entre ese reflejo y el viewDIr, y con esto calculamos el efecto en la variable specularity y de igual manera se lo agregamos a nuestra variable c.
-Para agregar el mapa de textura y el mapa de normales con su strength necesitaremos de MainTex la cual es de tipo 2D al igual que NormalTex, aquí es donde agregaremos la textura y su normal, para calcular la intensidad de nuestro mapa de normal utilizamos NormalStrength el cual es de tipo rango y dentro de nuestra función surf agregamos la textura a nuestro albedo, y el mapa de normal lo agregamos a la normal de nuestro SurfaceOutput.
-Para el rim utilizaremos un RImColor para nuestro color el cual será tipo HDR para que tenga una mejor calidad y un RImPower que será de tipo rango, para controlar la intensidad del efecto y  en nuestro surf lo calculamos utilizando el viewDir y el producto punto entre ese viewDir y la normal, para después invertirlo y lograr el efecto, después lo pasamos al Emission de nuestro SurfaceOutput el cual devuelve la intensidad del color sobre la superficie.
- Para crear el efecto banded necesitamos los Steps que serán de tipo rango, con los cuales calcularemos la distancia entre cada cambio de tono en el color, también ocuparemos el multiplicador que lo calcularemos con nuestros Steps sobre 256 el cual es el estándar, y el aditivo, después lo calculamos utilizando un floor para redondearlo al entero más cercano y lo agregamos a nuestra variable c.
-Para el ramp utilizamos RampTex que es de tipo 2D, donde agregaremos nuestra textura ramp y dentro del Lighting lo calculamos utilizando el NdotL para saber en que posición en x se encuentra ya que la altura no nos interesa y de igual manera lo agregamos a la variable c.
