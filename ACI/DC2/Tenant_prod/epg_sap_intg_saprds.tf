/*
GUI Location:
Tenants > prod > Application Profiles > sap_intg > Application EPGs > saprds
API Information:
 - Class: "fvAEPg"
 - Distinguished Name: /uni/tn-prod/ap-sap_intg/epg-saprds
*/
resource "aci_application_epg" "sap_intg_saprds" {
	depends_on						= [aci_application_profile.sap_intg]
	application_profile_dn			= aci_application_profile.sap_intg.id
	name							= "saprds"
	description						= "SAP HANA - Remote Data Sync"
	flood_on_encap					= "disabled"
	fwd_ctrl						= "none"
	has_mcast_source				= "no"
	is_attr_based_epg				= "no"
	match_t							= "AtleastOne"
	pc_enf_pref						= "disabled"
	pref_gr_memb					= "exclude"
	prio							= "level3"
	shutdown						= "no"
	relation_fv_rs_bd				= aci_bridge_domain.sap_itg.id
	relation_fv_rs_aepg_mon_pol		= "uni/tn-common/monepg-default"
}
