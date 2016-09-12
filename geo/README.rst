Trying to get ``location.lat`` and ``location.lon`` as fields.

This fails::

    ./delete.sh
    ./mapping.sh
    ./data.sh
    # give it a sec to index
    ./search.sh

This works::

    ./delete.sh
    ./fixed_mapping.sh
    ./data.sh
    # give it a sec to index
    ./search.sh

