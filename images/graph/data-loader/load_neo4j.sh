#!/usr/bin/env bash

DATABASE=graph.db

# If the destination database exists (graph.db)
# then leave...
if [ ! -d /data/databases/${DATABASE} ]; then

    echo "(load_neo4j.sh) Importing into '${DATABASE}'..."
    cd /data-loader
    /var/lib/neo4j/bin/neo4j-admin import \
        --database ${DATABASE} \
        --nodes "nodes-header.csv,nodes.csv" \
        --relationships:F2EDGE "edges-header.csv,edges.csv" \
        --ignore-duplicate-nodes

    echo "(load_neo4j.sh) Imported."
    touch loaded
    cd /var/lib/neo4j
    /var/lib/neo4j/bin/neo4j-shell -p ${DATABASE} -f << EOF
    CREATE INDEX ON :F2(smiles);
    schema await
    EOF
fi
