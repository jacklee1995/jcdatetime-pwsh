#*****************************************************************************
# Mouule: jcstudio.datetime
# Author: jclee95
# Chinese name: 李俊才
# Email: 291148484@163.com
# Author blog: https://blog.csdn.net/qq_28550263?spm=1001.2101.3001.5343
# Copyright Jack Lee. All rights reserved.
# Licensed under the MIT License.
#*****************************************************************************


class ValueError {
    ValueError(){
        throw "[Valueerror]: "
    }
    ValueError($s){
        throw "[Valueerror]: "+$s
    }
}

class StaticFuncs {
    static [System.Collections.ArrayList]range([int]$a, [int]$b){
        $temp = [System.Collections.ArrayList]@();
        if($a -eq $b){
            return $temp;
        }
        elseif($a -lt $b){
            $i = $a;
            while ($i -lt $b) {
                $temp.Add($i);
                $i = $i + 1;
            }
            return $temp;
        }
        else{
            $i = $b;
            while ($i -lt $a) {
                $temp.Add($i);
                $i = $i + 1;
            }
            return $temp;
        }
    }

    static [System.Collections.ArrayList]range([int]$a){
        $temp = [System.Collections.ArrayList]@();
        $i = 0;
        while ($i -lt $a) {
            $temp.Add($i);
            $i = $i + 1;
        }
        return $temp
    }

    <# Returns the number of days in a month. #>
    static [int]get_days([string]$yearmonth){
        $year, $month = $yearmonth.Split("/");
        $year = $year  -as [int];
        $month = $month  -as [int];
        $days = @{1=31; 3=31; 5=31; 7=31; 8=31; 10=31; 12=31; 4=30; 6=30; 9=30; 11=30};
        # leap year
        if($year%4 -ne 0){
            $days[2] = 28
        }
        else{
            $days[2] = 29 
        }
        return $days[$month]
    }

    <# Judging whether a certain month is a big month (31 days) #>
    static [bool]is_big_month([int]$month){
        if([StaticFuncs]::get_days($month) -eq 31){
            return $true;
        }
        else{
            return $false
        }
    }

    <# Returns a string list of all dates in a month. #>
    static [string[]] get_calendar([string]$yearmonth) {
        $year, $month = $yearmonth.Split("/")
        $days = [StaticFuncs]::get_days($yearmonth)
        $calendar_list = [System.Collections.ArrayList]@();
    
        foreach ($i in [StaticFuncs]::range(1, $days+1)) {
            $temp_j = $i.ToString()
            if($i.ToString().Length -eq 1){
                $j = '0' + $temp_j
            }
            else{
                $j = $temp_j
            }
            $aday = $year + "/" + $month + "/" + $j
            $calendar_list.Add($aday)
        }
        return $calendar_list
    }

    static [string]next_month([int] $year, [int] $month){
        if($month -lt 12){
            return ($year.ToString() + "/0" +  ($month + 1).ToString());
        }
        elseif ($month -eq 12) {
            return ($year + 1).ToString() + "/" + "01"; 
        }
        else{
            [ValueError]::new("Month must be less than or equal to 12.");
        }
        return ""
    }

    <# Returns a string list of dates. The format of  date_begin and date_end is like 2022/08/15 #>
    static [string[]] datelist([string]$date_begin, [string]$date_end) {
        $year_begin, $month_begin, $day_begin = $date_begin.Split("/");
        $year_end,   $month_end,   $day_end   = $date_end.Split("/");
        $date_list =  [System.Collections.ArrayList]@();

        $yearmonth = ($year_begin + $month_begin) -as [int];
        $yearmonth_end = ($year_end + $month_end) -as [int];

        while($yearmonth -le $yearmonth_end){
            
            $month_calendar = [StaticFuncs]::get_calendar($year_begin + "/" + $month_begin);
            foreach ($i in $month_calendar) {
                if (
                    ($i.Replace("/","") -as [int]) -ge ($date_begin.Replace("/","") -as [int]) 
                ) {
                    if(
                        ($i.Replace("/","") -as [int]) -le ($date_end.Replace("/","") -as [int])
                    ){
                        $date_list.Add($i);
                    }
                }
            }
            $yearmonth = [StaticFuncs]::next_month(
                $yearmonth.ToString().Substring(0,4) -as [int],
                $yearmonth.ToString().Substring(4,2) -as [int]
            )
            $year_begin = $yearmonth.Split("/")[0].ToString()
            $month_begin = $yearmonth.Split("/")[1].ToString()
            $yearmonth = $yearmonth.Replace("/","") -as [int]
        }
        return $date_list
    }
}

function Get-Today(){
    return (Get-Date).ToString().Split(" ")[0]
}

function Get-Present-Time() {
    return (Get-Date).ToString().Split(" ")[1]
}

<# Carrier state enumeration #>
enum CarryEnum {
    CARRY = 1;    # Carry
    NONE = 0;     # No Carry or BACK
    BACK = 2;     # BACK
}

<# Carry device. #>
class Carry{
    [int]$_value
    Carry(){
        $this._value = [CarryEnum].NONE;
    }
    Carry([CarryEnum]$b){
        $this._value = $b;
    }

    <# Mark carry. #>
    [void]set(){
        $this._value = [CarryEnum]::CARRY;
    }

    <# Mark back. #>
    [void]set_back(){
        $this._value = [CarryEnum]::BACK;
    }

    <# Clear mark. #>
    [void]clear(){
        $this._value =[CarryEnum]::NONE;
    }

    <# Get the carrier status. #>
    [int]get_state(){
        return $this._value;
    }
}

<# Seconds counter #>
class Second{
    [int]$_value=0
    [Carry]$c;
    Second([int]$s){
        $this.c = [Carry]::new()
        $this.c.clear();
        if($s -lt 0){
            [ValueError]::new("Seconds must be greater than or equal to 0.")
        }elseif ($s -gt 59) {
            [ValueError]::new("Seconds must be less than or equal to 59.")
        }
        $this._value = $s;
    }
    <# Forward walking #>
    [void]next(){
        # Has reached 59.
        if($this._value -ge 59){
            $this._value = 0;     # Empty
            $this.c.set();        # Mark carry
        }
        else{
            $this._value = $this._value + 1;
        }
        # Write-Host $this._value
    }

    <# Reverse walking #>
    [void]last(){
        # Has reached 0
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # Mark back
        }
        else{
            $this._value = $this._value - 1;
        }
        # Write-Host $this._value
    }

    [void]print(){
        $temp = $this._value.ToString();
        Write-Output $temp;
    }

    [string]get_value(){
        $s = $this._value.ToString();
        if($s.Length -eq 1){
            $s = "0" + $s;
        }
        return  $s;
        
    }
}

<# Minute counter #>
class Minute {
    [int]$_value=0;               # Needle position
    [Carry]$c;                    # carry
    [Second]$second;                   # Second hand position
    Minute([int]$m, [int]$s) {
        # Initialize the reference object of the advance and retreat flag.
        $this.c = [Carry]::new();
        $this.c.clear();

        # Check initial value
        if($m -lt 0){
            [ValueError]::new("Minutes must be greater than or equal to 0.")
        }elseif ($m -gt 59) {
            [ValueError]::new("Minutes must be less than or equal to 59.")
        }

        # Initialize the second reference object.
        $this.second = [Second]::new($s);

        # Set the initial value of minute hand.
        $this._value = $m;
    }

    <# Walk forward (minute hand, that is, the next minute) #>
    [void]next(){
        # Has reached 59.
        if($this._value -ge 59){
            $this._value = 0;     # Empty
            $this.c.set();        # Mark carry
        }
        else{
            $this._value = $this._value + 1;
        }
    }

    <#Walk in the opposite direction (minute hand, that is, the last minute) #>
    [void]last(){
        # 0 has arrived.
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # Mark back
        }
        else{
            $this._value = $this._value - 1;
        }
    }

    <# Walking forward (second hand, that is, the next second) #>
    [void]next_second(){
        # Call the next method of the Second class directly.
        $this.second.next();
        
        # Judge carry
        if($this.second.c.get_state() -eq [CarryEnum]::CARRY){
            # carry
            $this.next();
            # Clear the carry flag
            $this.second.c.clear()
        }
    }


    <# Walk in the opposite direction (second hand, that is, the last second) #>
    [void]last_second(){
        # 直接调用 Second 类的上一秒
        $this.second.last();
        # 判断退位
        if($this.second.c.get_state() -eq [CarryEnum]::BACK){
            # 先完成退位
            $this.last();
            # 再将进位标志清空
            $this.second.c.clear()
        }
    }

    [void]print(){
        $temp = $this._value.ToString() + ":" + $this.second._value.ToString()
        Write-Output $temp;
    }

    [string]get_value(){
        $m = $this._value.ToString();
        if($m.Length -eq 1){
            $m = "0" + $m;
        }
        return  $m + ":" + $this.second.get_value();
        
    }

    [int]get_minute(){
        return $this._value;
    }

    [int]get_second(){
        return $this.second.get_value();
    }
}

<# Hour counter #>
class Hour {
    [int]$_value=0;                    # 时针位
    [Carry]$c;                         # 进位
    [Minute]$minute;                   # 分针位（带秒位）

    # 使用当前的系统时间进行初始化
    Hour(){
        $h, $m, $s = (Get-Date).ToString().Split(" ")[1].Split(":");
        
        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);
        
        # 设置小时初值
        $this._value = $h;
    }

    # Initialized by the time represented by a string. 字符串形如 20:30:00
    Hour([string]$time){
        $h, $m, $s = $time.Split(":");

        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);
        
        # 设置小时初值
        $this._value = $h;
    }

    # 指定具体时间进行初始化：分别指定时、分、秒
    Hour([int]$h, [int]$m, [int]$s) {
        # 初始化分进退位标志引用对象
        $this.c = [Carry]::new();
        $this.c.clear();

        # 初始值校验
        if($h -lt 0){
            [ValueError]::new("Hours must be greater than or equal to 0.")
        }elseif ($h -gt 59) {
            [ValueError]::new("Hours must be less than or equal to 59.")
        }

        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);

        # 设置小时初值
        $this._value = $h;
    } 

    <# Walk forward (hour hand, that is, the next hour) #>
    [void]next(){
        # 已达 59
        if($this._value -ge 59){
            $this._value = 0;     # 置空
            $this.c.set();        # 标志进位
        }
        else{
            $this._value = $this._value + 1;
        }
    }

    <# Walk in the opposite direction (hour hand, that is, last hour) #>
    [void]last(){
        # 已到 0
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # 标志退位
        }
        else{
            $this._value = $this._value - 1;
        }
    }

    <# Walk forward (minute hand, that is, the next minute) #>
    [void]next_minute() {
        # 掉用分的下一分钟方法
        $this.minute.next();
        # 只需要观察分种是否进位
        if($this.minute.c._value -eq [CarryEnum]::CARRY){
            # 先进位到小时，即求下一小时
            $this.next();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }


    <# Walk in the opposite direction (minute hand, that is, the last minute) #>
    [void]last_minute() {
        # 掉用分的上一分钟方法
        $this.minute.last();
        # 只需要观察分种是否退位
        if($this.minute.c._value -eq [CarryEnum]::BACK){
            # 先求上一小时
            $this.last();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }


    <# Walking forward (second hand, that is, the next second) #>
    [void]next_second() {
        # 掉用分的下一秒方法
        $this.minute.next_second();
        # 只需要观察分种是否进位
        if($this.minute.c._value -eq [CarryEnum]::CARRY){
            # 先进位到小时，即求下一小时
            $this.next();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }

    <# Walk in the opposite direction (second hand, that is, the last second) #>
    [void]last_second() {
        # 调用分钟上一秒方法
        $this.minute.last_second()
        # 只需要观察分种是否退位
        if($this.minute.c._value -eq [CarryEnum]::BACK){
            # 先求上一小时
            $this.last();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }

    [void]print(){
        $temp = $this._value.ToString() + ":" + $this.minute._value.ToString() + ":" + $this.minute.s._value.ToString();
        Write-Output $temp;
    }

    [string]get_value(){
        $h = ($this._value).ToString();
        if($h.Length -eq 1){
            $h = "0" + $h;
        }
        return $h + ":" + $this.minute.get_value();
    }

    [int]get_hour(){
        return $this._value;
    }

    [int]get_minute(){
        return $this.minute.get_minute();
    }

    [int]get_second(){
        return $this.minute.get_second();
    }

}

<# Date counter #>
class Date {
    [int]$year
    [int]$month
    [int]$day

    # Initialize to the current date.
    Date(){
        $y, $m, $d = (Get-Date).ToString().Split(" ")[0].Split("/");

        $this.year = $y;
        $this.month = $m;
        $this.day = $d;

        # 数据校验
        $this._d_check();
    }

    # 以分别指定的指定年、月、日的形式初始化
    Date([int]$y, [int]$m, [int]$d){
        $this.year = $y;
        $this.month = $m;
        $this.day = $d;

        # 数据校验
        $this._d_check();
    }

    # Initializes the specified date with a string, such as `2022/05/26`
    Date([string]$date){
        $yyyy,$mm,$dd = $date.Split("/");
        $this.year = $yyyy -as [int];
        $this.month = $mm -as [int];
        $this.day = $dd -as [int];

        # 数据校验
        $this._d_check();
    }

    _d_check(){
        if ($this.year -le 0) {
            Write-Host ("year = "+$this.year);
            [ValueError]::new("Year must be greater than 0.")
        }
        if ($this.month -le 0) {
            [ValueError]::new("Month must be greater than 0.")
        }
        if ($this.day -le 0) {
            [ValueError]::new("Day must be greater than 0.")
        }
    }

    <# Returns whether the current year is a leap year. #>
    [bool]is_leap_year(){
        if(($this.year % 4) -eq 0){
            return $true;
        }else{
            return $false;
        }
    }

    <# The next day (tomorrow), return a new Date object. #>
    [Date]next(){
        $yearmonth = $this.year.ToString() + "/" + $this.month.ToString();
        $days = [StaticFuncs]::get_days($yearmonth);
        
        if($this.day -lt $days) {
            $next_day = ($this.day +1).ToString();
            $next_month = $this.month.ToString();
            $next_year = $this.year.ToString();
            return [Date]::new($next_year, $next_month, $next_day);
        }
        elseif ($this.day -eq $days) {
            $next_day = "01";
            if($this.month -lt 1){
                [ValueError]::new("An impossible year, which is less than 1.")
            }
            elseif($this.month -lt 12) {
                $next_month = ($this.month+1).ToString();
                $this_year = $this.year.ToString();
                return [Date]::new($this_year, $next_month, $next_day);
            }
            elseif($this.month -eq 12){
                $next_month = "01";
                $next_year = ($this.year + 1).ToString();
                return [Date]::new($next_year, $next_month, $next_day);
            }
            else{
                [ValueError]::new("An impossible year, which is greater than 12.")
            }
            
        }
        else{
            [ValueError]::new("An impossible date, which is greater than the number of days in the month.")
        }
        return [Date]::new(0, 13, 32);
    }

    <# Last day (yesterday), a new Date object was returned. #>
    [Date]last(){
        if ($this.day -ne 1) {

            $last_day = ($this.day - 1).ToString()
            $last_month = $this.month.ToString();
            $last_year = $this.year.ToString();

            return [Date]::new($last_year, $last_month, $last_day)
        }
        # $this.day -eq 1
        else{
            if($this.month -ne 1){

                $last_month = ($this.month -1).ToString();
                if($last_month.Length -eq 1){
                    $last_month = '0' + $last_month;
                }

                $last_year = $this.year.ToString();
                $yearmonth = $last_year + "/" + $last_month;
                $days = [StaticFuncs]::get_days($yearmonth);
                $last_day = $days.ToString();

                return [Date]::new($last_year, $last_month, $last_day)
            }
            # $this.month -eq 1
            else{
                $last_month = "12";
                $last_year = ($this.year-1).ToString();
                $yearmonth = $this.year.ToString() + "/" + $this.month.ToString();
                $days = [StaticFuncs]::get_days($yearmonth);
                $last_day = $days.ToString();
                return [Date]::new($last_year, $last_month, $last_day);
            }
        }
    }

    <# N days ago, a new Date object was returned #>
    [Date]ndays_ago([int]$n){
        $temp = [Date]::new($this.year, $this.month, $this.day);
        foreach ($i in [StaticFuncs]::range(0, $n)) {
            $temp = $temp.last();
        }
        return $temp
    }

    <# N days later, a new Date object is returned #>
    [Date]ndays_later([int]$n){
        $temp = [Date]::new($this.year, $this.month, $this.day);
        foreach ($i in [StaticFuncs]::range(0, $n)) {
            $temp = $temp.next();
        }
        return $temp
    }

    <# From the current start, the next n-1 Date objects form a list and return it. #>
    [Date[]]ndaylist_next([int]$n){
        $today = [Date]::new($this.year, $this.month, $this.day);
        $temp = [System.Collections.ArrayList]::new();
        foreach ($i in [StaticFuncs]::range($n)) { 
            $temp.Add($today);
            $today = $today.next();
        }
        return $temp
    }

    <# From now on, the first n-1 Date objects form a list and return it. #>
    [Date[]]ndaylist_last([int]$n){
        $today = [Date]::new($this.year, $this.month, $this.day);
        $temp = [System.Collections.ArrayList]::new();
        foreach ($i in [StaticFuncs]::range($n)) { 
            $temp.Add($today);
            $today = $today.last();
        }
        return $temp
    }

    [string]get_value(){
        $m = $this.month.ToString()
        if($m.Length -eq 1){
            $m = "0" + $m;
        }
        $d = $this.day.ToString()
        if($d.Length -eq 1){
            $d = "0" + $d;
        }
        return $this.year.ToString() + "/" + $m + "/" + $d;
    }

    [string]print(){
        $temp = $this.year.ToString() + "/" + $this.month.ToString() + "/" + $this.day.ToString();
        Write-Host $temp;
        return $temp
    }
}

<# Date time object #>
class DateTime {
    [Date]$date
    [Hour]$time

    # 例如字符串 `2022/05/26 20:59:25`
    DateTime([string]$dtm){
        $d, $t = $dtm.Split(" ");
        $this.date = [Date]::new($d);
        $this.time = [Date]::new($t);
    }

    <# The last second can be used as a second countdown timer. #>
    [void] last_second(){
        $this.time.last_second();
        # 若产生退位
        if($this.time.c._value -eq [CarryEnum]::BACK){
            # 完成从时间到日期的退位
            $this.date.last();
            # 清空退位标志
            $this.time.c.clear();
        }
    }

    <# The next second can be used as a second timer. #>
    [void] next_second(){
        $this.time.next_second();
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            $this.date.next();
            $this.time.c.clear();
        }
    }

    <# Last minute, can be used as a minute countdown timer. #>
    [void] last_minute(){
        $this.time.last_minute();
        if($this.time.c._value -eq [CarryEnum]::BACK){
            $this.date.last();
            $this.time.c.clear();
        }
    }

    <# The next minute can be used as a minute timer. #>
    [void] next_minute(){
        $this.time.next_minute();
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            $this.date.next();
            $this.time.c.clear();
        }
    }

    <# Last hour. Can be used as an hour countdown timer. #>
    [void] last_hour(){
        $this.time.last();
        # 若产生退位
        if($this.time.c._value -eq [CarryEnum]::BACK){
            # 完成从时间到日期的退位
            $this.date.last();
            # 清空退位标志
            $this.time.c.clear();
        }
    }

    <# Next hour. Can be used as an hour timer. #>
    [void] next_hour(){
        $this.time.next();
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            $this.date.next();
            $this.time.c.clear();
        }
    }

    [void] last_day(){
        $this.date.last();
    }

    [void] next_day(){
        $this.date.next();
    }

    [void] next_month(){
        if($this.date.month -eq 2) {
            if($this.date.is_leap_year()){
                $this.date = $this.date.ndays_later(29);
            }else{
                $this.date = $this.date.ndays_later(28);
            }
        }
        elseif([StaticFuncs]::is_big_month($this.date.month)) {
            $this.date = $this.date.ndays_later(31);
        }
        else{
            $this.date = $this.date.ndays_later(30);
        }
    }

    [void] next_year(){
        if($this.date.year.is_leap_year()){
            if($this.date.year -eq 2){
                if($this.date.day -eq 29){
                    $this.date.day = 28;
                }
            }
        }
        if($this.date.year -eq 12){
            $this.date.year = 0;
        }else{
            $this.date.year = $this.date.year + 1;
        }
    }

    [string]get_value(){
        return $this.date.get_value() + " " + $this.time.get_value();
    }

}


