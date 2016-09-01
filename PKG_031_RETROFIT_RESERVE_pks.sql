CREATE OR REPLACE PACKAGE DBO.pkg_031_retrofit_reserve IS

	/**********************************************************************************
	* Package: PKG_031_RETROFIT_RESERVE
	*
	* Description: Procedures to load tables for Retrofit Reserve Reporting
	*
    * Author: Jill Blank
    *
    * Create Date: 10/1/2008
    *
    * Revisions (add change revision information here if it applies to entire package)
    *
    *   Change Date              Developer                Change Description (include TTP if it applies to entire pkg)
      *   -----------              ---------                ------------------------------------------
    *   10/14/2008           Bashkar Shanmugam      Adding new Procedure for loading data into DBO.SY_031_CLAIM_SUM_STG table.
    *   10/22/2008           Jaishankar SP          Added new Procedure (p_load_retrofit_reserve) for loading data into DBO.DM_031_RETROFIT_RSV table
    *   10/28/2008           Jaishankar SP          Added Global Parameter (G_RUN) to the procedures
    *    2/12/2009           Jill Blank             TTP 7120 Changed p_load_claim_sum_stg to remove date upper limit
    ***********************************************************************************/

    PROCEDURE p_load_retrofit_id;

    PROCEDURE p_load_claim_sum_stg(G_RUN  IN DATE);
    PROCEDURE p_load_retrofit_reserve_main(G_RUN IN DATE);
    PROCEDURE p_del_retro_rsv_older_run(G_RUN IN DATE);

END;
/