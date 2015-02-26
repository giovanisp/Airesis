a1 = Continente.create(description: "Europe")
a1.translations.where(locale: "en").first_or_create.update_attributes(description: "Europe")
a1.translations.where(locale: "it-IT").first_or_create.update_attributes(description: "Europa")
s1 = Stato.create(description: "Italy", continente_id: a1.id, sigla: "IT", sigla_ext: "ITA")
s1.translations.where(locale: "it-IT").first_or_create.update_attributes(description: "Italia")
s1.translations.where(locale: "en").first_or_create.update_attributes(description: "Italy")
r14 = Regione.create(description: "Emilia Romagna", stato_id: s1.id, continente_id: a1.id)
Provincia.create(description: "Bologna", regione_id: r14.id, stato_id: s1.id, continente_id: a1.id, sigla: "BO"){ |c| c.id = 57}.save
Comune.create(description: "Bologna", provincia_id: 57, regione_id: r14.id, stato_id: 1, continente_id: 1 , population: 371217)
Comune.create(description: "Marzabotto", provincia_id: 57, regione_id: r14.id, stato_id: 1, continente_id: 1 , population: 6262)
Comune.create(description: "Medicina", provincia_id: 57, regione_id: r14.id, stato_id: 1, continente_id: 1 , population: 13570)

load File.join(Rails.root, 'db', 'seeds', "228_airesis_seed.rb")