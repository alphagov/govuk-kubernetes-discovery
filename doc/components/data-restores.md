# Data Restores

## Mongodb ##

### Steps ###

This will import a mongo database into an existing cluster (see "content-store-import.sh" for more).

1. Download a tarball of the database to be imported
2. Untar and select the appropriate databases (in the case of content-store 'admin' and 'content_store_production')
3. Tar the file
4. Copy the file to the cluster (in this case using `kubectl cp`)
5. Get a shell on the primary mongo instance (`kubectl exec -ti <pod> -- bash`)
6. Disable `failIndexKeyTooLong`
7. untar the file and restore it using `mongorestore --drop <untarred dir>`
