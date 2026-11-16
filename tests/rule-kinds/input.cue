package test

Input: {
	db:     {name: "db", "@type": {Database: true}}
	cache:  {name: "cache", "@type": {Cache: true}}
	mon:    {name: "mon", "@type": {Monitor: true}, depends_on: {api: true}}
	api:    {name: "api", "@type": {Service: true}, depends_on: {db: true}}
	worker: {name: "worker", "@type": {Service: true}, depends_on: {cache: true}}
	web:    {name: "web", "@type": {Frontend: true}, depends_on: {api: true}}
	batch:  {name: "batch", "@type": {Service: true}}
}
