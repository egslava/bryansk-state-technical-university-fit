﻿
# encoding: UTF-8
#Егоренков 08-ПО1

## №        ||     Сn3        || Вид пыли       || Сведения об источнике пыли                            ||	
##варианта 	||    мг/м^3      ||  % SiO2        || H, м       || Д, м      || V, м^3/ч    || Tr, K       ||
N = 16      ;   Cn = 13000.0  ;   Dust="10-70"  ;   H = 75.0  ;   D = 1.2  ;   V = 11000.0;   Tr = 335.0 ;
#n = 16      ;   Cn = 13000.0  ;   dust="10-70"  ;   H = 75.0  ;   D = 1.2  ;   V = 11000.0;   Tr = 335.0 ;

A	= 140.0;	# для Московской, Тульской, Рязанской, Владимирской, Калужской, Ивановской и Брянской областей
F	= 2.5;		# Мы всегда берём только Кремний 
NU 	= 1.0;	#Тоже жёстко забит
DT 	= Tr - 295.5;# Температура по Брянску - температура по варианту. Это дельта-T


PDKmr = {"2-10" => 0.5, "10-70" => 0.3 , ">70" => 0.15}[Dust];
PDKrz = {"2-10" => 4.0, "10-70" => 1.0 , ">70" => 1.00}[Dust];

# результаты
#Сmr_warm = 0; PDKrz_warm = 0;  M_warm = 0; PDV_warm = 0; Z_warm = 0; Xm_warm = 0;
#Сmr_cold = 0; PDKrz_cold = 0;  M_cold = 0; PDV_cold = 0; Z_cold = 0; Xm_cold = 0;

PRECISE = 2;

#Нужно, чтобы, если что, можно было просто создать веб-морду
def log (*args) 
	puts args
end

###########################################################
# Дальше не хуй лесть
###########################################################

$step = 0;

# формула №7
$step += 1;
@m7 = ((Cn * V) / (3600 * (10 ** 3))).round(PRECISE);

log <<COMMENT

#{$step}. Находим массу вредного вещества, выбрасываемого в
   атмосферу, в единицу времени г/с по формуле (3):

         C * V
   M = ----------
                3
       3600 * 10
   
       #{Cn} * #{V}
   M = ------------------- = #{@m7}
                    3
           3600 * 10

COMMENT

# формула №8
$step += 1;
V_1 = 	((V * Tr) / 
		(273 * 3600)).round(PRECISE);
log <<COMMENT
                              3
#{$step}. Объём газовоздушной смеси м / c, 
   находим по формуле (8):
           V * T
                r
   V =  ------------
    1    273 * 3600


        #{V} * #{Tr}
   V =  ----------------  = #{V_1}
    1    273.0 * 3600.0

COMMENT


# формула №11
$step += 1;
W_0 = 	( V_1 / 
		(0.785 * D * D)).round(PRECISE);
log <<COMMENT
#{$step}. Расчитываем w   ("омега нулевое") - скорость выброса 
                0
   газовоздушной смеси из трубы, м/с; Д - диаметр трубы, м 
   По формуле (11):
             
              1
   W =  ------------
    0             2
         0.785 * Д


             #{V_1} 
   W =  ----------------  = #{W_0}
    0                  2
           0.785 * #{D}

COMMENT

# формула №10
$step += 1;
f = 	( (1000.0 * W_0 * W_0 * D ) / 
		  (H * H * DT )).round(PRECISE);
log <<COMMENT
#{$step}. Расчитываем вспомогательный параметр f по формуле (10)
                 2
                w   *   Д
         3       0
   f = 10  * ----------------
                2      
               H   * ▲T

                   2
         3     #{W_0}  * #{D} 
   f = 10  * ----------------  = #{f}
                   2
               #{H}  * #{DT}

COMMENT

# формула №9
$step += 1;
@m9 = 	( (1.0) / 
		  (0.67 +  0.1 * (f ** 0.5) + 0.34 * (f ** (1/3) ))).round(PRECISE);
log <<COMMENT
#{$step}. Безразмерный коэффициент m расчитывают по формуле (9)
    
                            1
   m =  --------------------------------------
                      1/2           1/3
        0.67 + 0.1 * f    + 0.34 * f

                            1
   m =  -------------------------------------- = #{@m9}
                         1/2             1/3
        0.67 + 0.1 * #{f}    + 0.34 * #{f}

COMMENT

# формула №20
$step += 1;
Vm_warm = ((V_1 * DT / H) ** (1.0 / 3.0)).round(PRECISE);
log <<COMMENT
#{$step}. Вспомогательный параметр V  (опасная скорость газовоздушной 
                             М
  смеси) для НАГРЕТЫХ выбросов находим по формуле (20)

         _                _ 1/3  
        |   V    *      ▲T |
        |    1             |
   V =  | ---------------  |
    М   |_       H        _|


         _               _ 1/3  
        |   #{V_1} * #{DT}   |
   V =  | --------------- |   =  #{Vm_warm}
    М   |_      #{H}     _|

COMMENT

# формула  12, 13, 14
def n (_Vm)
	$step += 1;
	log "#{$step}. Расчитываем безразмерный коэффициент n. V   = #{_Vm}"
  log "                                             М          "
	if _Vm >= 2 then
		log "   n = 1 (V  >= 2, формула 12)"
    log "           М                  "
		1
	elsif (0.5 <= _Vm) and (_Vm < 2) then
		log ("                 2\n" +
   			 "   n = 0.582 * V   - 2.13 * V  + 3.13 (0.5 <= V  <= 2, формула 13)\n" +
         "                М            М                 М                  " )
		log ("                   2\n" +
			 "   n = 0.582 * #{_Vm}   - 2.13 * #{_Vm} + 3.13 ")

		result = 0.582 * (_Vm ** 2) - 2.13 * _Vm + 3.13;
		log "   n = #{result}"
		result
	else
		log "   n = 4.4 * V , при V  < 0.5 (формула 14)";
    log "              М       М                   ";
		log "   n = #{4.4 * _Vm}";
		4.4 * _Vm
	end
end

$n_warm = n(Vm_warm)

# Формула №3
def Cmr_warm ()

	# A в условии
	# M #формула7	OK!
	# F в условии	
  # m #формула9	OK! m9
	# n #формула12, #формула13, #формула14 OK!
	# NU в условии (жёстко-забитый коэффициент)
	# H в условии (высота трубы, м)
	# V1 #формула8  OK!
	# dT определяем в самом начале (для Брянска)
	$step += 1;
	result = ((A * @m7 * F * @m9 * $n_warm * NU) / 
			 (H **2 * ((V_1 * DT) ** (1.0/3.0)) )).round(2);
log <<PRINT
#{$step}. Находим C      для нагретых выбросов по формуле (3):
            M.P.
   Формула 3:
               (A * M  * F * m * n * nu)
   C     =    -------------------------
    M.P.             2             1/3
                    H   *  (V * ▲T)
                             1


               (#{A} * #{@m7}  * #{F} * #{@m9} * #{$n_warm} * #{NU})
   C      =    ---------------------------------------------        = #{result}
    M.P.            2                 1/3
                #{H}  * (#{V_1} * #{DT})
PRINT

	result 

end

Cmr_warm_result = Cmr_warm();

# Приложение №3
$step += 1;
log <<COMMENT
#{$step}. По приложению №3 (таблица) находим предельно допустимую концентрацию 
   кремния в рабочей зоне:

   ПДК    =  #{PDKmr}
      M.P.
COMMENT

# Приложение №3
$step += 1;
log <<COMMENT
#{$step}. По приложению №3 (таблица) находим предельно допустимую концентрацию
   кремния в рабочей зоне:

   ПДК    =  #{PDKrz}
      Р.З.
COMMENT

# формула №4
$step += 1;
PDV_warm = ( PDKmr * (H ** 2 * ((V_1 * DT) ** (1.0/3.0)) )/
             (A * F * @m9 * $n_warm * NU) ).round(2);
log <<PRINT
#{$step}. Находим ПДВ для нагретых выбросов по формуле (4):
    Формула 4:
                            2               1/3
                 ПДК    *  H  * (  V * ▲T  )
                    M.P.            1 
    ПДВ =    ----------------------------------
                      (A * F * m * n * nu) 


                               2                1/3
                    #{PDKmr}  * #{H}  * (#{V_1} * #{DT})
    ПДВ =    -------------------------------------------------   = #{PDV_warm}
                   (#{A} * #{F} * #{@m9} * #{$n_warm} * #{NU})
PRINT

$step += 1;
Z_warm = ( (@m7 - PDV_warm) / @m7 * 100.0).round(2);
log <<PRINT
#{$step}. Расчитываем требуемую степень очистки Z для нагретых выбросов по
    формуле (22):
            M - ПВД
    Z  =  --------- * 100
              M

            #{@m7} - #{PDV_warm}
    Z  =  --------------- * 100 = #{Z_warm}
              #{@m7}

PRINT

# формула №18, №19
def B(_Vm, f, temp)
  $step += 1;
  log "#{$step}. Значение безразмерного коэффициента Б для #{temp} выбросов "
  if _Vm <= 2 then
    result = (4.95 * _Vm * (1 + 0.28 * (f ** (1.0/3.0)))).round(2);
    log <<COMMENT
    находим по формуле (18), т.к. V  <= 2  (V  = #{_Vm}):
                                   М         М          
                                  1/3
    Б = 4.95 * V   * (1 + 0.28 * f   )
                М 

                                        1/3
    Б = 4.95 * #{_Vm}   * (1 + 0.28 * #{f}   ) = #{result}
COMMENT
    result
  else
    result = 7.00 * (_Vm ** (1.0/2.0)) * (1 + 0.28 * (f ** (1.0/3.0)));
    log <<COMMENT
    находим по формуле (19), т.к. V  > 2  (V  = #{_Vm}):
                                            М          
             2                 1/3
    Б = 7 * V   * (1 + 0.28 * f   )
             М 

                  2             1/3
    Б = 7 * #{_Vm}   * (1 + 0.28 * #{f}   ) = #{result}
COMMENT
    result;
  end
end

# формула №18, №19
def Xm(_F, _B, _H, temp)
  $step += 1;
  log "#{$step}. Расстояние от источника выброса #{temp} вредного  "
  log "    вещества, на котором устанавливается C      определяется"
  log "                                          М.Р."
  if _F < 2 then
    result = (_B * _H).round(2);
    log <<COMMENT
    по формуле (16), т.к. F  < 2  (F  = #{_F}):
                                                       
                                  1/3
    X = Б * Н
     М       
                     
    X = #{_B} * #{_H}  = #{result}
     М
COMMENT
    
  else
    result = ( (5.0 - _F) / 4.0 * _B * _H).round(2);
    log <<COMMENT
    по формуле (17), т.к. F  >= 2  (F  = #{_F}):

           5 - F      
    X  =  ------- * Б * Н
     М       4 

           5 - #{_F}      
    X  =  --------- * #{_B} * #{_H} = #{result}
     М       4 
COMMENT
  end

  result
end

B_warm = B(Vm_warm, f, "нагретых");

Xm_warm = Xm(F, B_warm, H, "нагретого");

# формула №15
$step += 1;
K = (  ( D * 3600.0 )/
       ( 8.0 * V    )).round(2);
log <<PRINT

==================================================================
Для того, чтобы найти С     и ПДВ для холодных выбросов, надо
                       М.Р.
найти коэффициент "К" и пересчитать параметры "n" и "V " 
                                                      М
==================================================================
                         2
#{$step}. Коэффициент K ( с / м  ) определяют по формуле (15):
    Формула 15:
              Д * 3600
    K   =    ----------
                8 * V            

              #{D}  * 3600
    K   =    ---------------   = #{K}
              8 * #{V}
PRINT


# формула №21
$step += 1;
Vm_cold = (1.3 * W_0 / H).round(PRECISE);
log <<COMMENT
#{$step}. Вспомогательный параметр V  (опасная скорость газовоздушной 
                              М
   смеси) для ХОЛОДНЫХ выбросов находим по формуле (21)  (w - "омега нулевое" )
                                                           0
   Формула 21:
                  w
                   0
   V =  1.3  --------------- 
    М             H

                  #{W_0}
   V =  1.3  ---------------  = #{Vm_cold}
    М             #{H}

COMMENT

n_cold = n(Vm_cold);

# формула №5
$step += 1;
Cmr_cold = (K * A * @m7 * F * n_cold *  NU / (H ** (4.0/3.0))).round(PRECISE);
log <<COMMENT
#{$step}. Находим C    для холодных выбросов по формуле (5):
             M.P.
    Formula 5:
             A * M * F * n * nu     
   C    =  -------------------- * K
    M.P.              4/3
                     H

             #{A} * #{@m7} * #{F} * #{n_cold} * #{NU}     
   C    =  --------------------------------------- * #{K} = #{Cmr_cold}
    M.P.                 4/3
                     #{H}
COMMENT


$step += 1;
PDV_cold = ( PDKmr * (H ** (4.0/3.0))/
             (A * F * n_cold * NU * K) ).round(2);
log <<PRINT
#{$step}. Находим ПДВ для холодных выбросов по формуле (6):
    Формула 6:
                                4/3
                     ПДК    *  H    
                        M.P.
    ПДВ =    -------------------------
                A * F * n * nu * L


                                    4/3
                         #{PDKmr}  * #{H}  
    ПДВ =    ----------------------------------------   = #{PDV_cold}
               #{A} * #{F} * #{n_cold} * #{NU} * #{K}
PRINT

$step += 1;
Z_cold = ( (@m7 - PDV_cold) / @m7 * 100.0).round(2);

log <<PRINT
#{$step}. Расчитываем требуемую степень очистки Z  для холодных выбросов по
    формуле (22):
            M - ПДВ
    Z  =  --------- * 100
              M

            #{@m7} - #{PDV_cold}
    Z  =  --------------- * 100 = #{Z_cold}
              #{@m7}

PRINT

B_cold = B(Vm_cold, f, "холодных");
Xm_cold = Xm(F, B_cold, H, "холодного");

puts "Выпишем полученные результаты в таблицу:"
puts ".----------.----------.----------.----------.----------.----------.----------.----------."
puts "|Выбросы   |    C     |   C      | ПДК      |    M,    |   ПДВ,   |     Z,   |     X    |"
puts "|          |     п    |    М.Р.  |    Р.З.  |          |          |          |      М   |"
puts "|          |        3 |      3   |      3   |          |          |          |          |"
puts "|          |     мг/м |  мг/м    |  мг/м    |   г/с    |   г/с    |     %    |     M    |"
puts "|----------|----------|----------|----------|----------|----------|----------|----------|"
printf "|Нагретые  |%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|\n", Cn, Cmr_warm_result, PDKrz, @m7, PDV_warm, Z_warm, Xm_warm
puts "|----------|----------|----------|----------|----------|----------|----------|----------|"
printf "|Холодные  |%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|%-10.2f|\n", Cn, Cmr_cold, PDKrz, @m7, PDV_cold, Z_cold, Xm_cold
puts "'----------'----------'----------'----------'----------'----------'----------'----------'"