/*
 * users who have their collation set to US format (MYD) will
 * get a 'date out of range' error when casting dates here.
 *
 * Force it to DMY.
 *
 * If you are unsure what yours is, check with
 *
 * show lc_collate;
 */
set datestyle to DMY;

insert into schools (
    urn,
    ukprn,
    la_code,
    establishment_code,
    name,
    establishment_type,
    establishment_type_group,
    open,
    opened_on,
    closed_on,
    censused_on,
    pupils,
    boys,
    girls,
    gender,
    coordinates,
    phase,
    local_authority,
    government_office_region,
    free_school_meals_percentage,
    start_age,
    finish_age,
    capacity,
    rural_urban_classification,
    email_address,
    trust_code,
    trust_name,
    headteacher_name,
    street,
    locality,
    address3,
    town,
    county,
    postcode,
    website,
    telephone_num,
    updated_at
)

select
    sr."URN"::integer,
        case --ukprn
            when (sr."UKPRN" is null or sr."UKPRN" = '')
                then null
            else
                sr."UKPRN"::integer
	end,
    nullif(sr."LA (code)", '')::integer,
    nullif(sr."EstablishmentNumber", '')::integer,
	sr."EstablishmentName",
	sr."TypeOfEstablishment (name)"::establishment,
	sr."EstablishmentTypeGroup (name)"::establishment_group,

	case -- open
	when (sr."EstablishmentStatus (name)" = 'Open' or sr."EstablishmentStatus (name)" = 'Open, but proposed to close')
		then true
	else -- "Proposed to open" or "Closed"
		false
	end,

	case -- opened_on
	when (sr."OpenDate" is null or sr."OpenDate" = '')
		then null
	else
		sr."OpenDate"::date
	end,

	case -- closed_on
	when (sr."CloseDate" is null or sr."CloseDate" = '')
		then null
	else
		sr."CloseDate"::date
	end,

	case -- censused_on
	when (sr."CensusDate" is null or sr."CensusDate" = '')
		then null
	else
		sr."CensusDate"::date
	end,

	nullif(sr."NumberOfPupils", '')::integer,
	nullif(sr."NumberOfBoys", '')::integer,
	nullif(sr."NumberOfGirls", '')::integer,
	nullif(sr."Gender (name)", '')::gender,

	case -- coordinates
	when (sr."Easting" = '' or sr."Northing" = '')
		then null
	else
		/*
		 * convert to WGS84 (EPSG:4326), the *standard* coordinate system that's
		 * used in GPS and online mapping tools
		 *
		 * https://en.wikipedia.org/wiki/World_Geodetic_System
		 */
		st_transform(
			/*
			 * transform the raw point to a British National Grid (EPSG:27700) one,
			 * this is the format used by The Ordinance Survey
			 *
			 * https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid
			 */
			st_setsrid(
				/*
				 * return a point with an unknown SRID using the raw easting/northing
				 * values
				 *
				 * https://en.wikipedia.org/wiki/Easting_and_northing
				 */
				st_makepoint(
					sr."Easting"::integer,
					sr."Northing"::integer
				),
				27700
			),
			4326
		)
	end,

	nullif(sr."PhaseOfEducation (name)", '')::phase,
	sr."LA (name)",
	case -- government_office_region
	when sr."GOR (name)" = 'Not Applicable'
		then null
	when sr."GOR (name)" = 'Wales (pseudo)'
		then 'Wales'::government_office_region
	when sr."GOR (name)" = 'Yorkshire and the Humber'
		then 'Yorkshire and The Humber'::government_office_region
	else
		sr."GOR (name)"::government_office_region
	end,
	nullif(sr."PercentageFSM", '')::decimal,
	nullif(sr."StatutoryLowAge", '')::integer,
	nullif(sr."StatutoryHighAge", '')::integer,
	nullif(sr."SchoolCapacity", '')::integer,
	/*
	 * upper case all of the classifications to standardise
	 */
    LEFT(
        upper(
            replace(
                replace(
                    nullif(sr."UrbanRural (name)", ''),
                    '(England/Wales) ',
                    ''
                ),
                '(Scotland) ',
                ''
            )
        ),
        63
    )::rural_urban_classification,
	nullif(ear."MailEmail", ''),
	nullif(sr."Trusts (code)", '')::integer,
	nullif(sr."Trusts (name)", ''),

	nullif(sr."HeadFirstName" || ' ' || sr."HeadLastName", ''),
    nullif(sr."Street", ''),
    nullif(sr."Locality", ''),
    nullif(sr."Address3", ''),
    nullif(sr."Town", ''),
    nullif(sr."County (name)", ''),
    nullif(sr."Postcode", ''),
    nullif(sr."SchoolWebsite", ''),
    nullif(sr."TelephoneNum", ''),
    current_timestamp
from
	schools_raw sr
left outer join
	email_addresses_raw ear
		on sr."URN" = ear."URN"
;