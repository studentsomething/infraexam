# PGR301 Eksamen


## Oppsett:

- Fyll ut pipeline.yml, bytt ut de to repo'ene til ditt repo.
- Ingen endringer kreves i heroku.tf. Postgres resursene er med vilje kommentert ut.
- Fyll in heroku mail i provider_heroku.tf
- Add statuscake username in statuscake.tf
- Edit variablename in variables.tf if needed
- Delete terraform.st if I accidently forgot to delete ut
- Fill out credentials.yml. I belive the fields are self-explanable from what I can read in the examtask.


### Videre når dette er gjort kan Docker og videre Concourse imaget startes.

Kommando for å logge inn med fly er ```fly --target tutorial login --concourse-url http://127.0.0.1:8080 -u admin -p admin```

Etterfulgt av ```fly -t tutorial sp  -p heroku-example06 -c concourse/pipeline.yml -l credentials.yaml```

Unpause så pipelinen enten med kommando eller i GUIet. Og start infrajobben. Når denne har fullført kreves det et manuelt steg (mer om dette lenger ned).

Gå inn i Heroku, for hver app i pipelinen må HOSTEDGRAPHITE_HOST settes som config variabel. Denne variablen hentes fra HostedGraphite og vil være ulik for hvert miljø.

Etter dette kan appen deployes.

## Oppgaver som er løst/forsøkt løst/forsøkt

- Basis oppgaven er så vidt jeg tolker det løst. Infra fungerer og appen blir deployet til Heroku med slug. Den kan videre bringes til staging/prod.
- Logging. System.out's er erstatted med logback som sender til Logz.io. Her vil alle miljøer sende til samme sted. Testlogging vil printe ut i konsoll og ikke sende til logz.io. Var usikker på hva som er vanlig her, så tenkte det ville være en fin måte å vise to muligheter på hvor "produksjon" sender til logz.io og testkode sender til konsol.
- Metrics. Her fikk jeg startet men ikke helt fullført. Se under:

Jeg fikk lagt til en kjapp "mark" for å bekrefte at koden funker. Den blir sendt til graphite, hvor jeg får opp innkommende TCP. Fikk derimot ikke gjort noe særlig mer rundt denne annet enn å sende inn enkel mark for å bekrefte oppsett.

Var også veldig usikker på hvordan HOST kan automatisk settes, så at dette ble diskutert på forumet men fikk ikke dette til. 

Jeg har IKKE forsøkt å løse Docker og Google Cloud Functions.

## Problemer og utfordringer:

- Docker, Postgres out of space.
Fikk et problem mandag kveld, som jeg greide å hacke meg rundt med restart av Docker. Samme problem oppsto tirsdag kveld, og da tenkte jeg det var på tide å løse det ordentlig. 
Etter litt try and failure fant jeg til slutt denne karen som med veldig få steg løste problemet. Så kudos til han!

Takk til https://stackoverflow.com/questions/43111587/docker-error-no-space-left-on-device-on-windows# 

Viste seg at det ikke hjalp mer enn en kjøring.. Måtte da ty til litt tips herfra som til slutt satte meg på sporet av at Docker imaget var brukt opp.
Og litt tips og triks herfra: https://github.com/fabric8io/jenkinshift/blob/master/vendor/github.com/docker/docker/docs/articles/b2d_volume_resize.md

## Kodedesign
Som det skinner veldig igjennom er ikke mitt REST-API allverden. Det er ingen sjekker, ingen eller liten tilbakemelding og total mangel på HTTP tilbakemeldinger. Det er lese, skrive og slette operasjoner mens det er mangel på oppdatering. Så ikke fullverdig CRUD. 

## Testing
Da jeg ikke fikk gjort veldig mye, fokuserte jeg ikke ekstremt mye på testing av applikasjonen. Det er mer eller mindre kun et par tester for å vise prinsippet. 
Var også litt usikker på om det er logisk at eventuelle logger i tester logges direkte til konsollen (med logback) eller til logz.io. Jeg valgte det første.
Er derimot fullt klar over at hvis testloggene skal sendes til logz.io er det kun å endre logback-test.xml fila.

## Mistenkelig repo
Det ser muligens litt mistenkelig ut at jeg har commited veldig lite.. *Grunnen til dette var at jeg hadde en initial commit i mitt arbeidsrepo bundet til min email. Så på forespørsmål så gjør jeg gjerne dette repoet public så eventuelle juksemistanker blir oppklart.



PS: For å nå REST-API'et som selvfølgelig ikke er dokumentert med Swagger (det sto på min ToDo liste). Men det er en aldri så liten guide som hjemskjerm.

