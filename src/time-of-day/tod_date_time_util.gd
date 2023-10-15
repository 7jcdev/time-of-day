class_name TOD_DateTimeUtil

## Total hours in earth
const TOTAL_HOURS: int = 24

## Compute leap year
static func compute_leap_year(year: int) -> bool:
	return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)

## Convert hour to float.
static func hour_to_total_hours(hour: int) -> float:
	return float(hour)

## Convert hours to float.
static func hour_minutes_to_total_hours(hour: int, minutes: int) -> float:
	return float(hour) + float(minutes) / 60.0

## Convert hours to float.
static func hours_to_total_hours(hour:int, minutes: int, seconds: int) -> float:
	return float(hour) + float(minutes) / 60.0 + float(seconds) / 3600.0

## Convert hours to float.
static func full_time_to_total_hours(hour: int, minutes: int, seconds: int, milliseconds: int) -> float: 
	return float(hour) + float(minutes) / 60.0 + float(seconds) / 3600.0 +\
		float(milliseconds) / 3600000.0	
