from PySSC import PySSC
import pandas as pd
df_loc = pd.read_csv('Location100.csv')
for i in range(1,2):
	for j in range(2011,2012):
		if __name__ == "__main__":
			ssc = PySSC()
			print ('Current folder = C:/Users/aramanuj/wind_data')
			print ('SSC Version = ', ssc.version())
			print ('SSC Build Information = ', ssc.build_info().decode("utf - 8"))
			ssc.module_exec_set_print(0)
			data = ssc.data_create()
			ssc.data_set_number( data, b'wind_resource_model_choice', 0 )	
			ssc.data_set_string( data, b'wind_resource_filename', b'C:/Users/aramanuj/wind_new_data/r1_2011.srw');
			wind_resource_distribution = [[ 3.1185,   45,   0.0344 ], [ 9.1355000000000004,   45,   0.0172 ], [ 15.1525,   45,   0.000457 ], [ 21.169499999999999,   45,   0 ], [ 3.1185,   135,   0.046800000000000001 ], [ 9.1355000000000004,   135,   0.0591 ], [ 15.1525,   135,   0.0032000000000000002 ], [ 21.169499999999999,   135,   0.00011400000000000001 ], [ 3.1185,   225,   0.063799999999999996 ], [ 9.1355000000000004,   225,   0.28199999999999997 ], [ 15.1525,   225,   0.26300000000000001 ], [ 21.169499999999999,   225,   0.0487 ], [ 3.1185,   315,   0.062399999999999997 ], [ 9.1355000000000004,   315,   0.0974 ], [ 15.1525,   315,   0.020500000000000001 ], [ 21.169499999999999,   315,   0.0010300000000000001 ]];
			ssc.data_set_matrix( data, b'wind_resource_distribution', wind_resource_distribution );
			ssc.data_set_number( data, b'weibull_reference_height', 50 )
			ssc.data_set_number( data, b'weibull_k_factor', 2 )
			ssc.data_set_number( data, b'weibull_wind_speed', 7.25 )
			ssc.data_set_number( data, b'wind_resource_shear', 0.14000000000000001 )
			ssc.data_set_number( data, b'wind_turbine_rotor_diameter', 21 )
			wind_turbine_powercurve_windspeeds =[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ];
			ssc.data_set_array( data, b'wind_turbine_powercurve_windspeeds',  wind_turbine_powercurve_windspeeds);
			wind_turbine_powercurve_powerout =[ 0, 0, 0.5, 4.0999999999999996, 10.5, 19, 29.399999999999999, 41, 54.299999999999997, 66.799999999999997, 77.700000000000003, 86.400000000000006, 92.799999999999997, 97.799999999999997, 100, 99.900000000000006, 99.200000000000003, 98.400000000000006, 97.5, 96.799999999999997, 96.400000000000006, 96.299999999999997, 96.799999999999997, 98, 99.200000000000003 ];
			ssc.data_set_array( data, b'wind_turbine_powercurve_powerout',  wind_turbine_powercurve_powerout);
			ssc.data_set_number( data, b'wind_turbine_hub_ht', 160 )
			ssc.data_set_number( data, b'wind_turbine_max_cp', 0.41999999999999998 )
			ssc.data_set_number( data, b'wind_farm_wake_model', 0 )
			ssc.data_set_number( data, b'wind_resource_turbulence_coeff', 0.10000000000000001 )
			ssc.data_set_number( data, b'system_capacity', 100 )
			wind_farm_xCoordinates =[ 0 ];
			ssc.data_set_array( data, b'wind_farm_xCoordinates',  wind_farm_xCoordinates);
			wind_farm_yCoordinates =[ 0 ];
			ssc.data_set_array( data, b'wind_farm_yCoordinates',  wind_farm_yCoordinates);
			ssc.data_set_number( data, b'wake_int_loss', 0 )
			ssc.data_set_number( data, b'wake_ext_loss', 1.1000000000000001 )
			ssc.data_set_number( data, b'wake_future_loss', 0 )
			ssc.data_set_number( data, b'avail_bop_loss', 0.5 )
			ssc.data_set_number( data, b'avail_grid_loss', 1.5 )
			ssc.data_set_number( data, b'avail_turb_loss', 3.5800000000000001 )
			ssc.data_set_number( data, b'elec_eff_loss', 1.9099999999999999 )
			ssc.data_set_number( data, b'elec_parasitic_loss', 0.10000000000000001 )
			ssc.data_set_number( data, b'env_degrad_loss', 1.8 )
			ssc.data_set_number( data, b'env_exposure_loss', 0 )
			ssc.data_set_number( data, b'env_env_loss', 0.40000000000000002 )
			ssc.data_set_number( data, b'env_icing_loss', 0.20999999999999999 )
			ssc.data_set_number( data, b'ops_env_loss', 1 )
			ssc.data_set_number( data, b'ops_grid_loss', 0.83999999999999997 )
			ssc.data_set_number( data, b'ops_load_loss', 0.98999999999999999 )
			ssc.data_set_number( data, b'ops_strategies_loss', 0 )
			ssc.data_set_number( data, b'turb_generic_loss', 1.7 )
			ssc.data_set_number( data, b'turb_hysteresis_loss', 0.40000000000000002 )
			ssc.data_set_number( data, b'turb_perf_loss', 1.1000000000000001 )
			ssc.data_set_number( data, b'turb_specific_loss', 0.81000000000000005 )
			ssc.data_set_number( data, b'adjust:constant', 0 )
			ssc.data_set_number( data, b'total_uncert', 12.085000000000001 )
			ssc.data_set_number( data, b'system_use_lifetime_output', 0 )
			ssc.data_set_number( data, b'analysis_period', 25 )
			ssc.data_set_array_from_csv( data, b'load', b'C:/Users/aramanuj/wind_data/load.csv');
			load_escalation =[ 0 ];
			ssc.data_set_array( data, b'load_escalation',  load_escalation);
			ssc.data_set_array_from_csv( data, b'grid_curtailment', b'C:/Users/aramanuj/wind_data/grid_curtailment.csv');
			ssc.data_set_number( data, b'enable_interconnection_limit', 0 )
			ssc.data_set_number( data, b'grid_interconnection_limit_kwac', 100000 )
			ssc.data_set_number( data, b'inflation_rate', 2.5 )
			degradation =[ 0 ];
			ssc.data_set_array( data, b'degradation',  degradation);
			rate_escalation =[ 0 ];
			ssc.data_set_array( data, b'rate_escalation',  rate_escalation);
			ssc.data_set_number( data, b'ur_metering_option', 0 )
			ssc.data_set_number( data, b'ur_nm_yearend_sell_rate', 0 )
			ssc.data_set_number( data, b'ur_nm_credit_month', 11 )
			ssc.data_set_number( data, b'ur_nm_credit_rollover', 0 )
			ssc.data_set_number( data, b'ur_monthly_fixed_charge', 30 )
			ssc.data_set_number( data, b'ur_monthly_min_charge', 0 )
			ssc.data_set_number( data, b'ur_annual_min_charge', 0 )
			ssc.data_set_number( data, b'ur_en_ts_sell_rate', 0 )
			ssc.data_set_array_from_csv( data, b'ur_ts_sell_rate', b'C:/Users/aramanuj/wind_data/ur_ts_sell_rate.csv');
			ssc.data_set_number( data, b'ur_en_ts_buy_rate', 0 )
			ssc.data_set_array_from_csv( data, b'ur_ts_buy_rate', b'C:/Users/aramanuj/wind_data/ur_ts_buy_rate.csv');
			ur_ec_sched_weekday = [[ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ]];
			ssc.data_set_matrix( data, b'ur_ec_sched_weekday', ur_ec_sched_weekday );
			ur_ec_sched_weekend = [[ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ]];
			ssc.data_set_matrix( data, b'ur_ec_sched_weekend', ur_ec_sched_weekend );
			ur_ec_tou_mat = [[ 1,   1,   9.9999999999999998e+37,   0,   0.12,   0 ]];
			ssc.data_set_matrix( data, b'ur_ec_tou_mat', ur_ec_tou_mat );
			ssc.data_set_number( data, b'ur_dc_enable', 1 )
			ur_dc_sched_weekday = [[ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ]];
			ssc.data_set_matrix( data, b'ur_dc_sched_weekday', ur_dc_sched_weekday );
			ur_dc_sched_weekend = [[ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ], [ 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1 ]];
			ssc.data_set_matrix( data, b'ur_dc_sched_weekend', ur_dc_sched_weekend );
			ur_dc_tou_mat = [[ 1,   1,   100,   50 ]];
			ssc.data_set_matrix( data, b'ur_dc_tou_mat', ur_dc_tou_mat );
			ur_dc_flat_mat = [[ 0,   1,   9.9999999999999998e+37,   0 ], [ 1,   1,   9.9999999999999998e+37,   0 ], [ 2,   1,   9.9999999999999998e+37,   0 ], [ 3,   1,   9.9999999999999998e+37,   0 ], [ 4,   1,   9.9999999999999998e+37,   0 ], [ 5,   1,   9.9999999999999998e+37,   0 ], [ 6,   1,   9.9999999999999998e+37,   0 ], [ 7,   1,   9.9999999999999998e+37,   0 ], [ 8,   1,   9.9999999999999998e+37,   0 ], [ 9,   1,   9.9999999999999998e+37,   0 ], [ 10,   1,   9.9999999999999998e+37,   0 ], [ 11,   1,   9.9999999999999998e+37,   0 ]];
			ssc.data_set_matrix( data, b'ur_dc_flat_mat', ur_dc_flat_mat );
			ssc.data_set_number( data, b'ur_enable_billing_demand', 0 )
			ssc.data_set_number( data, b'ur_billing_demand_minimum', 100 )
			ssc.data_set_number( data, b'ur_billing_demand_lookback_period', 11 )
			ur_billing_demand_lookback_percentages = [[ 60,   0 ], [ 60,   0 ], [ 60,   0 ], [ 60,   0 ], [ 60,   0 ], [ 95,   1 ], [ 95,   1 ], [ 95,   1 ], [ 95,   1 ], [ 60,   0 ], [ 60,   0 ], [ 60,   0 ]];
			ssc.data_set_matrix( data, b'ur_billing_demand_lookback_percentages', ur_billing_demand_lookback_percentages );
			ur_dc_billing_demand_periods = [[ 1,   1 ], [ 2,   1 ]];
			ssc.data_set_matrix( data, b'ur_dc_billing_demand_periods', ur_dc_billing_demand_periods );
			ur_yearzero_usage_peaks =[ 234.67599999999999, 173.422, 172.00700000000001, 191.434, 198.29499999999999, 236.46899999999999, 274.23099999999999, 260.33600000000001, 226.751, 185.12299999999999, 156.19999999999999, 184.05000000000001 ];
			ssc.data_set_array( data, b'ur_yearzero_usage_peaks',  ur_yearzero_usage_peaks);
			federal_tax_rate =[ 21 ];
			ssc.data_set_array( data, b'federal_tax_rate',  federal_tax_rate);
			state_tax_rate =[ 7 ];
			ssc.data_set_array( data, b'state_tax_rate',  state_tax_rate);
			ssc.data_set_number( data, b'property_tax_rate', 0 )
			ssc.data_set_number( data, b'prop_tax_cost_assessed_percent', 100 )
			ssc.data_set_number( data, b'prop_tax_assessed_decline', 0 )
			ssc.data_set_number( data, b'real_discount_rate', 6.4000000000000004 )
			ssc.data_set_number( data, b'insurance_rate', 0 )
			ssc.data_set_number( data, b'loan_term', 25 )
			ssc.data_set_number( data, b'loan_rate', 4 )
			ssc.data_set_number( data, b'debt_fraction', 80 )
			om_fixed =[ 0 ];
			ssc.data_set_array( data, b'om_fixed',  om_fixed);
			ssc.data_set_number( data, b'om_fixed_escal', 0 )
			om_production =[ 0 ];
			ssc.data_set_array( data, b'om_production',  om_production);
			ssc.data_set_number( data, b'om_production_escal', 0 )
			om_capacity =[ 37 ];
			ssc.data_set_array( data, b'om_capacity',  om_capacity);
			ssc.data_set_number( data, b'om_capacity_escal', 0 )
			ssc.data_set_number( data, b'depr_fed_type', 1 )
			ssc.data_set_number( data, b'depr_fed_sl_years', 7 )
			depr_fed_custom =[ 0 ];
			ssc.data_set_array( data, b'depr_fed_custom',  depr_fed_custom);
			ssc.data_set_number( data, b'depr_sta_type', 1 )
			ssc.data_set_number( data, b'depr_sta_sl_years', 7 )
			depr_sta_custom =[ 0 ];
			ssc.data_set_array( data, b'depr_sta_custom',  depr_sta_custom);
			ssc.data_set_number( data, b'itc_fed_amount', 0 )
			ssc.data_set_number( data, b'itc_fed_amount_deprbas_fed', 1 )
			ssc.data_set_number( data, b'itc_fed_amount_deprbas_sta', 1 )
			ssc.data_set_number( data, b'itc_sta_amount', 0 )
			ssc.data_set_number( data, b'itc_sta_amount_deprbas_fed', 0 )
			ssc.data_set_number( data, b'itc_sta_amount_deprbas_sta', 0 )
			ssc.data_set_number( data, b'itc_fed_percent', 26 )
			ssc.data_set_number( data, b'itc_fed_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'itc_fed_percent_deprbas_fed', 1 )
			ssc.data_set_number( data, b'itc_fed_percent_deprbas_sta', 1 )
			ssc.data_set_number( data, b'itc_sta_percent', 0 )
			ssc.data_set_number( data, b'itc_sta_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'itc_sta_percent_deprbas_fed', 0 )
			ssc.data_set_number( data, b'itc_sta_percent_deprbas_sta', 0 )
			ptc_fed_amount =[ 0 ];
			ssc.data_set_array( data, b'ptc_fed_amount',  ptc_fed_amount);
			ssc.data_set_number( data, b'ptc_fed_term', 10 )
			ssc.data_set_number( data, b'ptc_fed_escal', 0 )
			ptc_sta_amount =[ 0 ];
			ssc.data_set_array( data, b'ptc_sta_amount',  ptc_sta_amount);
			ssc.data_set_number( data, b'ptc_sta_term', 10 )
			ssc.data_set_number( data, b'ptc_sta_escal', 0 )
			ssc.data_set_number( data, b'ibi_fed_amount', 0 )
			ssc.data_set_number( data, b'ibi_fed_amount_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_fed_amount_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_fed_amount_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_fed_amount_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_sta_amount', 0 )
			ssc.data_set_number( data, b'ibi_sta_amount_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_sta_amount_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_sta_amount_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_sta_amount_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_uti_amount', 0 )
			ssc.data_set_number( data, b'ibi_uti_amount_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_uti_amount_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_uti_amount_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_uti_amount_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_oth_amount', 0 )
			ssc.data_set_number( data, b'ibi_oth_amount_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_oth_amount_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_oth_amount_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_oth_amount_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_fed_percent', 0 )
			ssc.data_set_number( data, b'ibi_fed_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'ibi_fed_percent_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_fed_percent_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_fed_percent_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_fed_percent_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_sta_percent', 0 )
			ssc.data_set_number( data, b'ibi_sta_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'ibi_sta_percent_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_sta_percent_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_sta_percent_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_sta_percent_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_uti_percent', 0 )
			ssc.data_set_number( data, b'ibi_uti_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'ibi_uti_percent_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_uti_percent_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_uti_percent_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_uti_percent_deprbas_sta', 0 )
			ssc.data_set_number( data, b'ibi_oth_percent', 0 )
			ssc.data_set_number( data, b'ibi_oth_percent_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'ibi_oth_percent_tax_fed', 1 )
			ssc.data_set_number( data, b'ibi_oth_percent_tax_sta', 1 )
			ssc.data_set_number( data, b'ibi_oth_percent_deprbas_fed', 0 )
			ssc.data_set_number( data, b'ibi_oth_percent_deprbas_sta', 0 )
			ssc.data_set_number( data, b'cbi_fed_amount', 0 )
			ssc.data_set_number( data, b'cbi_fed_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'cbi_fed_tax_fed', 1 )
			ssc.data_set_number( data, b'cbi_fed_tax_sta', 1 )
			ssc.data_set_number( data, b'cbi_fed_deprbas_fed', 0 )
			ssc.data_set_number( data, b'cbi_fed_deprbas_sta', 0 )
			ssc.data_set_number( data, b'cbi_sta_amount', 0 )
			ssc.data_set_number( data, b'cbi_sta_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'cbi_sta_tax_fed', 1 )
			ssc.data_set_number( data, b'cbi_sta_tax_sta', 1 )
			ssc.data_set_number( data, b'cbi_sta_deprbas_fed', 0 )
			ssc.data_set_number( data, b'cbi_sta_deprbas_sta', 0 )
			ssc.data_set_number( data, b'cbi_uti_amount', 0 )
			ssc.data_set_number( data, b'cbi_uti_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'cbi_uti_tax_fed', 1 )
			ssc.data_set_number( data, b'cbi_uti_tax_sta', 1 )
			ssc.data_set_number( data, b'cbi_uti_deprbas_fed', 0 )
			ssc.data_set_number( data, b'cbi_uti_deprbas_sta', 0 )
			ssc.data_set_number( data, b'cbi_oth_amount', 0 )
			ssc.data_set_number( data, b'cbi_oth_maxvalue', 9.9999999999999998e+37 )
			ssc.data_set_number( data, b'cbi_oth_tax_fed', 1 )
			ssc.data_set_number( data, b'cbi_oth_tax_sta', 1 )
			ssc.data_set_number( data, b'cbi_oth_deprbas_fed', 0 )
			ssc.data_set_number( data, b'cbi_oth_deprbas_sta', 0 )
			pbi_fed_amount =[ 0 ];
			ssc.data_set_array( data, b'pbi_fed_amount',  pbi_fed_amount);
			ssc.data_set_number( data, b'pbi_fed_term', 0 )
			ssc.data_set_number( data, b'pbi_fed_escal', 0 )
			ssc.data_set_number( data, b'pbi_fed_tax_fed', 1 )
			ssc.data_set_number( data, b'pbi_fed_tax_sta', 1 )
			pbi_sta_amount =[ 0 ];
			ssc.data_set_array( data, b'pbi_sta_amount',  pbi_sta_amount);
			ssc.data_set_number( data, b'pbi_sta_term', 0 )
			ssc.data_set_number( data, b'pbi_sta_escal', 0 )
			ssc.data_set_number( data, b'pbi_sta_tax_fed', 1 )
			ssc.data_set_number( data, b'pbi_sta_tax_sta', 1 )
			pbi_uti_amount =[ 0 ];
			ssc.data_set_array( data, b'pbi_uti_amount',  pbi_uti_amount);
			ssc.data_set_number( data, b'pbi_uti_term', 0 )
			ssc.data_set_number( data, b'pbi_uti_escal', 0 )
			ssc.data_set_number( data, b'pbi_uti_tax_fed', 1 )
			ssc.data_set_number( data, b'pbi_uti_tax_sta', 1 )
			pbi_oth_amount =[ 0 ];
			ssc.data_set_array( data, b'pbi_oth_amount',  pbi_oth_amount);
			ssc.data_set_number( data, b'pbi_oth_term', 0 )
			ssc.data_set_number( data, b'pbi_oth_escal', 0 )
			ssc.data_set_number( data, b'pbi_oth_tax_fed', 1 )
			ssc.data_set_number( data, b'pbi_oth_tax_sta', 1 )
			ssc.data_set_number( data, b'total_installed_cost', 740000 )
			ssc.data_set_number( data, b'salvage_percentage', 0 )
			ssc.data_set_number( data, b'batt_salvage_percentage', 0 )
			module = ssc.module_create(b'windpower')	
			ssc.module_exec_set_print( 0 );
			if ssc.module_exec(module, data) == 0:
				print ('windpower simulation error')
				idx = 1
				msg = ssc.module_log(module, 0)
				while (msg != None):
					print ('	: ' + msg.decode("utf - 8"))
					msg = ssc.module_log(module, idx)
					idx = idx + 1
				SystemExit( "Simulation Error" );
			ssc.module_free(module)
			module = ssc.module_create(b'grid')	
			ssc.module_exec_set_print( 0 );
			if ssc.module_exec(module, data) == 0:
				print ('grid simulation error')
				idx = 1
				msg = ssc.module_log(module, 0)
				while (msg != None):
					print ('	: ' + msg.decode("utf - 8"))
					msg = ssc.module_log(module, idx)
					idx = idx + 1
				SystemExit( "Simulation Error" );
			ssc.module_free(module)
			module = ssc.module_create(b'utilityrate5')	
			ssc.module_exec_set_print( 0 );
			if ssc.module_exec(module, data) == 0:
				print ('utilityrate5 simulation error')
				idx = 1
				msg = ssc.module_log(module, 0)
				while (msg != None):
					print ('	: ' + msg.decode("utf - 8"))
					msg = ssc.module_log(module, idx)
					idx = idx + 1
				SystemExit( "Simulation Error" );
			ssc.module_free(module)
			module = ssc.module_create(b'cashloan')	
			ssc.module_exec_set_print( 0 );
			if ssc.module_exec(module, data) == 0:
				print ('cashloan simulation error')
				idx = 1
				msg = ssc.module_log(module, 0)
				while (msg != None):
					print ('	: ' + msg.decode("utf - 8"))
					msg = ssc.module_log(module, idx)
					idx = idx + 1
				SystemExit( "Simulation Error" );
			ssc.module_free(module)
			annual_energy = ssc.data_get_number(data, b'annual_energy');
			print ('Net electricity to grid (year 1) = ', annual_energy)
			capacity_factor = ssc.data_get_number(data, b'capacity_factor');
			print ('Capacity factor (year 1) = ', capacity_factor)
			lcoe_nom = ssc.data_get_number(data, b'lcoe_nom');
			print ('Levelized COE (nominal) = ', lcoe_nom)
			lcoe_real = ssc.data_get_number(data, b'lcoe_real');
			print ('Levelized COE (real) = ', lcoe_real)
			elec_cost_without_system_year1 = ssc.data_get_number(data, b'elec_cost_without_system_year1');
			print ('Electricity bill without system (year 1) = ', elec_cost_without_system_year1)
			elec_cost_with_system_year1 = ssc.data_get_number(data, b'elec_cost_with_system_year1');
			print ('Electricity bill with system (year 1) = ', elec_cost_with_system_year1)
			savings_year1 = ssc.data_get_number(data, b'savings_year1');
			print ('Net savings with system (year 1) = ', savings_year1)
			npv = ssc.data_get_number(data, b'npv');
			print ('Net present value = ', npv)
			payback = ssc.data_get_number(data, b'payback');
			print ('Simple payback period = ', payback)
			discounted_payback = ssc.data_get_number(data, b'discounted_payback');
			print ('Discounted payback period = ', discounted_payback)
			adjusted_installed_cost = ssc.data_get_number(data, b'adjusted_installed_cost');
			print ('Net capital cost = ', adjusted_installed_cost)
			first_cost = ssc.data_get_number(data, b'first_cost');
			print ('Equity = ', first_cost)
			loan_amount = ssc.data_get_number(data, b'loan_amount');
			print ('Debt = ', loan_amount)
			#ssc.data_free(data);
		n1 = range(0,8760)
		n2 = [number+0.5 for number in n1]
		df = pd.DataFrame()
		df['Time'] = n2
		P =  ssc.data_get_array(data, b'gen')
		df['Power'] = P[0:8760]
		#print(df_loc.iloc[i,0])
		#print(df_loc.iloc[i,0]+'_'+("% s" % j)+'.csv')
		df.to_csv('C:/Users/aramanuj/wind_new_data/'+df_loc.iloc[i,0]+'_'+("% s" % j)+'.csv')