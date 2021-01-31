/*
API Information:
 - Class: "fvAEPg"
 - Distinguished Name: /uni/tn-prod/ap-nets/epg-v0110
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v0110
*/
resource "aci_application_epg" "nets_v0110" {
	depends_on						= [aci_application_profile.nets]
	application_profile_dn			= aci_application_profile.nets.id
	name							= "v0110"
	description						= "inBandMgmt"
	flood_on_encap					= "disabled"
	fwd_ctrl						= "none"
	has_mcast_source				= "no"
	is_attr_based_epg				= "no"
	match_t							= "AtleastOne"
	pc_enf_pref						= "disabled"
	pref_gr_memb					= "exclude"
	prio							= "level3"
	shutdown						= "no"
	relation_fv_rs_bd				= aci_bridge_domain.v0110.id
	relation_fv_rs_aepg_mon_pol		= "uni/tn-common/monepg-default"
}

/*
API Information:
 - Class: "fvRsDomAtt"
 - Distinguished Name: /uni/tn-prod/ap-nets/epg-v0110/rsdomAtt-[uni/phys-access_phys]
GUI Location:
Tenants > prod > Application Profiles > nets > Application EPGs > v0110 > Domains (VMs and Bare-Metals)
*/
resource "aci_rest" "nets_v0110_phys-access_phys" {
	depends_on		= [aci_application_epg.nets_v0110]
	path		= "/api/node/mo/uni/tn-prod/ap-nets/epg-v0110.json"
	class_name	= "fvRsDomAtt"
	payload		= <<EOF
{
    "fvRsDomAtt": {
        "attributes": {
            "tDn": "uni/phys-access_phys"
        },
        "children": []
    }
}
	EOF
}

