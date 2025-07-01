## exercise
calories_burned	INTEGER	YES	NULL	
created_date	TEXT	YES	NULL	
duration_minutes	INTEGER	YES	NULL	
exercise_date	TEXT	NO	NULL	
exercise_name	TEXT	NO	NULL	
exercise_type	TEXT	NO	NULL	
id	TEXT	YES	NULL	
intensity	TEXT	YES	NULL	
is_deleted	INTEGER	YES	0	
is_synced	INTEGER	YES	0	
last_sync_date	TEXT	YES	NULL	
notes	TEXT	YES	NULL	
reps	INTEGER	YES	NULL	
sets	INTEGER	YES	NULL	
updated_date	TEXT	YES	NULL	
user_id	TEXT	YES	NULL	users(id)
weight	REAL	YES	NULL	

##food items
id	TEXT	YES	NULL	
name	TEXT	NO	NULL	
serving_size_g	REAL	YES	NULL	
calories	REAL	NO	NULL	
protein	REAL	NO	NULL	
carbohydrates	REAL	NO	NULL	
fat	REAL	NO	NULL	
created_date	TEXT	YES	NULL	
updated_date	TEXT	YES	NULL	
last_sync_date	TEXT	YES	NULL	
is_synced	INTEGER	YES	0	
is_deleted	INTEGER	YES	0	
is_sample	INTEGER	YES	0	

##meal_entry
id	TEXT	YES	NULL	
user_id	TEXT	YES	NULL	users(id)
food_item_id	TEXT	YES	NULL	food_items(id)
food_name	TEXT	NO	NULL	
meal_type	TEXT	NO	NULL	
quantity_g	REAL	NO	NULL	
entry_date	TEXT	NO	NULL	
calories	REAL	YES	NULL	
protein	REAL	YES	NULL	
carbohydrates	REAL	YES	NULL	
fat	REAL	YES	NULL	
created_date	TEXT	YES	NULL	
updated_date	TEXT	YES	NULL	
last_sync_date	TEXT	YES	NULL	
is_synced	INTEGER	YES	0	
is_deleted	INTEGER	YES	0	

##sqlite_sequence
name		YES	NULL	
seq		YES	NULL	

##users
id	TEXT	YES	NULL	
email	TEXT	YES	NULL	
name	TEXT	YES	NULL	
created_date	TEXT	YES	NULL	
updated_date	TEXT	YES	NULL	
last_sync_date	TEXT	YES	NULL	
is_synced	INTEGER	YES	0	

## workout_logs
id	INTEGER	YES	NULL	
session_id	TEXT	YES	NULL	
exercise_id	TEXT	NO	NULL	
sets	INTEGER	YES	NULL	
reps	INTEGER	YES	NULL	
weight	REAL	YES	NULL	
duration_seconds	INTEGER	YES	NULL	
notes	TEXT	YES	NULL	
workout_date	TEXT	NO	NULL	
created_at	TEXT	YES	"datetime('now')"	
sync_status	INTEGER	YES	1	

## workout_programs
id	TEXT	YES	NULL	
name	TEXT	NO	NULL	
creator	TEXT	NO	NULL	
description	TEXT	YES	NULL	
duration_weeks	INTEGER	NO	NULL	
difficulty_level	TEXT	NO	NULL	
program_type	TEXT	NO	NULL	
workouts_per_week	INTEGER	YES	NULL	
equipment_needed	TEXT	YES	NULL	
weekly_schedule	TEXT	YES	NULL	
tags	TEXT	YES	NULL	
rating	REAL	YES	NULL	
is_popular	INTEGER	YES	0	
created_date	TEXT	YES	NULL	
updated_date	TEXT	YES	NULL	
last_sync_date	TEXT	YES	NULL	
is_synced	INTEGER	YES	0	
is_deleted	INTEGER	YES	0	
is_sample	INTEGER	YES	0	

##workout_sessions
id	TEXT	YES	NULL	
user_id	TEXT	YES	NULL	users(id)
session_name	TEXT	NO	NULL	
start_time	TEXT	NO	NULL	
end_time	TEXT	YES	NULL	
total_duration_minutes	INTEGER	YES	NULL	
exercises	TEXT	YES	NULL	
is_completed	INTEGER	YES	0	
notes	TEXT	YES	NULL	
created_date	TEXT	YES	NULL	
updated_date	TEXT	YES	NULL	
last_sync_date	TEXT	YES	NULL	
is_synced	INTEGER	YES	0	
is_deleted	INTEGER	YES	0	
program_id	TEXT	YES	NULL	
program_day	TEXT	YES	NULL	
