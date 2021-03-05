# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra).
Jag kommer göra en "Hemlig" blocket, så att man alltså behöver inlogg för att kolla på annonser. Olika annonser kommer ha olika säkerhetsnivåer och olika konton kommer också ha olika säkerhetsnivåer. Man kommer kunna skapa, kolla och ta bort annonser. Konto är inget som görs, utan något man får.
## 2. Vyer (visa bildskisser på dina sidor).
#Loginsidan
![Image description](misc\Skisser\Login-page.jpg)
#Startsidan ifall du är inloggad
![Image description](misc\Skisser\Visa-annonser-olika-nivåer-av-security.jpg)
#Dina-annonser
![Image description](misc\Skisser\Dina-annonser.jpg)
#Andras annonser
![Image description](misc\Skisser\Andras-annonser(Beta).jpg)
#Skapa annonser
![Image description](misc\Skisser\Skapa-annonser.jpg)
## 3. Databas med ER-diagram (Bild på ER-diagram).
#Inte fullt färdig databas, men med alla grunder
![Image description](misc\ER-Diagram\5da85290f4a3392e28227a41337a05db.png)
## 4. Arkitektur (Beskriv filer och mappar - vad gör/innehåller de?).
Misc:
Här ligger alla misc filer som är till dokumentation och liknande

Model: 
I här ligger model.rb, den är model i MVC, den kommunicerar med databasen och filsystemet och har vissa helperfunktioner

Public: Här i ligger css-filen och hemsidans logo. Denna mapp är public så att alla nätet kommer ha möjlighet att se detta.

Views:
Här ligger alla slimfiler som har något med de andra filerna att göra.

App.rb:
Detta är controllern i MVC, den har alla routes som används och har blandannat hand om sessions osv.


