drop type if exists rural_urban_classification;

/*
 * the classifications are now all upper case because the Scottish exist in
 * multiple combinations of capitalisation, eg 'Large Urban Area', 'Large Urban
 * area' and 'Large urban area'
 */
create type rural_urban_classification as enum (
    -- England/Wales
    'RURAL TOWN AND FRINGE',
    'URBAN MAJOR CONURBATION',
    'URBAN CITY AND TOWN',
    'RURAL TOWN AND FRINGE IN A SPARSE SETTING',
    'RURAL VILLAGE',
    'URBAN MINOR CONURBATION',
    'RURAL HAMLET AND ISOLATED DWELLINGS',
    'RURAL HAMLET AND ISOLATED DWELLINGS IN A SPARSE SETTING',
    'URBAN CITY AND TOWN IN A SPARSE SETTING',
    'RURAL VILLAGE IN A SPARSE SETTING',

    -- Scotland
    'REMOTE RURAL',
    'ACCESSIBLE RURAL',
    'REMOTE SMALL TOWN',
    'OTHER URBAN AREA',
    'LARGE URBAN AREA',

    -- Urban (unspecified)
    'URBAN: NEARER TO A MAJOR TOWN OR CITY',
    'URBAN: FURTHER FROM A MAJOR TOWN OR CITY',

    -- Rural (unspecified)
    'LARGER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',
    'SMALLER RURAL: NEARER TO A MAJOR TOWN OR CITY',
    'LARGER RURAL: NEARER TO A MAJOR TOWN OR CITY',
    'SMALLER RURAL: FURTHER FROM A MAJOR TOWN OR CITY',

    -- Pseudo
    '(PSEUDO) CHANNEL ISLANDS/ISLE OF MAN'
);
