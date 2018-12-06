Infra for monitoring example


Oppsett:

- Fyll ut pipeline.yml, bytt ut de to repo'ene til ditt repo.
- Ingen endringer kreves i heroku.tf. Postgres resursene er med vilje kommentert ut.
- Fyll in heroku mail i provider_heroku.tf
- Add statuscake username in statuscake.tf
- Edit variablename in variables.tf if needed
- Delete terraform.st if I accidently forgot to delete ut
- Fill out credentials.yml. I belive the fields are self-explanable from what I can read in the examtask.


Problemer og utfordringer:

- Docker, Postgres out of space.
Fikk et problem mandag kveld, som jeg greide å hacke meg rundt med restart av Docker. Samme problem oppsto tirsdag kveld, og da tenkte jeg det var på tide å løse det ordentlig. 
Etter litt try and failure fant jeg til slutt denne karen som med veldig få steg løste problemet. Så kudos til han!

Takk til https://stackoverflow.com/questions/43111587/docker-error-no-space-left-on-device-on-windows# 

Viste seg at det ikke hjalp mer enn en kjøring.. Måtte da ty til litt tips herfra som til slutt satte meg på sporet av at Docker imaget var 62/64GB. 
Og litt tips og triks herfra: https://github.com/fabric8io/jenkinshift/blob/master/vendor/github.com/docker/docker/docs/articles/b2d_volume_resize.md

- App ble ikke deployet.

- Fant aldri ut hvordan jeg fant fram til Graphite Host. API_KEY blir jo automatisk lagret som env variabel i Heroku. Samtidig kan man lett finne hosten ved hjelp av GUI. Men hvordan denne automatisk skal finnes fant jeg ikke uta av.
Jeg har derfor kun testet at dette funket lokalt, for å vise at jeg forstår det grunnleggende av Graphite. Derimot funket det dessverre absolutt ikke med DevOps tankegang.
Prøvde ulike kommandoer for å hente denne verdien fra addons i heroku. Som heroku addons --json, som listet opp korrekt informasjon. Men hvordna mine kommandolinjeferdigheter var ikke nokfor å få denne verdien ut.
Skrev derimot kode klar i push_to_master_branch på stedet den skulle puttes inn.

Suggestions to cache Maven repositories between builds: https://stackoverflow.com/questions/40736296/how-to-cache-maven-repository-between-builds

Testing
Da jeg ikke fikk gjort veldig mye, fokuserte jeg ikke ekstremt mye på testing av applikasjonen. Det er mer eller mindre kun et par tester for å vise prinsippet. 
Var også litt usikker på om det er logisk at eventuelle logger i tester logges direkte til konsollen (med logback) eller til logz.io. Jeg valgte det første.
Er derimot fullt klar over at hvis testloggene skal sendes til logz.io er det kun å endre logback-test.xml fila.

PS: For å nå REST-API'et som selvfølgelig ikke er dokumentert med Swagger (det sto på min ToDo liste) bruk Localhost:x/customers.


