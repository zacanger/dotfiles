##Caveats

###Components

####Accessing store() from components

Not sure if this is just a workaround or what but:
https://stackoverflow.com/questions/18612030/access-store-from-component

###Adapter

When using the rails backend, use the DS.ActiveModelAdapter in the
application/adapter.js instead of DS.RESTAdapter.  This will ensure that URLS
and requests will be parsed using the expected rails-convention routes.
