
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

# результаты
#Сmr_warm = 0; PDKrz_warm = 0;  M_warm = 0; PDV_warm = 0; Z_warm = 0; Xm_warm = 0;
#Сmr_cold = 0; PDKrz_cold = 0;  M_cold = 0; PDV_cold = 0; Z_cold = 0; Xm_cold = 0;

PRECISE = 2;

#Нужно, чтобы, если что, можно было просто создать веб-морду
def log (*args) 
	puts (args)
end

###########################################################
# Дальше не хуй лесть
###########################################################

$step = 0;

# формула №7
$step += 1;
@m7 = ((Cn * V) / (3600 * (10 ** 3))).round(PRECISE);

log <<COMMENT

#{$step}. Nahodim massu vrednogo veshestva, vibrasivaemogo v
   atmosferu v edinicu vremeni r/c po formule (3):
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
#{$step}. Ob'' yom gazovosdushnoy smesi, m^3/c, 
   nahodim po formule (8):
           V * Tr
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
#{$step}. Raschitivaem W0 - skorost vihoda gazovosdushnoy
   smesi is trubi, m/c; D - diameter trubi, m po formule (11) 
             
              1
   W =  ------------
    0             2
         0.785 * D


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
#{$step}. Raschitivaem vspomogatelniy parametr f po formule (10)
                 2
                w   *   D
         3       0
   f = 10  * ----------------
                2      
               H   * deltaT

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
#{$step}. Bezrazmerniy coefficient m raschitivayut po formule (9)
    
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
#{$step}. Vspomogatelniy parametr Vm (opasnuyu skorost gazovozdushnoy
   smesi) dlya NAGRETIH vibrosov nahodim po formule (20)

         _                _ 1/3  
        |   V    *  deltaT |
        |    1             |
   V =  | ---------------  |
    m   |_       H        _|


         _               _ 1/3  
        |   #{V_1} * #{DT}   |
   V =  | --------------- |   =  #{Vm_warm}
    m   |_      #{H}     _|

COMMENT

# формула  12, 13, 14
def n (_Vm)
	$step += 1;
	log "#{$step}. Raschitivaem bezrazmerniy coefficient n. Vm = #{_Vm}"
	if _Vm >= 2 then
		log "   n = 1 (Vm >= 2, formula 12)"
		1
	elsif (0.5 <= _Vm) and (_Vm < 2) then
		log ("                 2\n" +
   			 "   n = 0.582 * Vm  - 2.13 * Vm + 3.13 (0.5 <= Vm <= 2, formula 13)")
		log ("                   2\n" +
			 "   n = 0.582 * #{_Vm}   - 2.13 * #{_Vm} + 3.13 ")

		result = 0.582 * (_Vm ** 2) - 2.13 * _Vm + 3.13;
		log "   n = #{result}"
		result
	elsif
		log "   n = 4.4 Vm, pri Vm < 0.5 (formula 14)"
		log "   n = #{4.4 * _Vm}"
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
#{$step}. Nahodim C_m.p. dlya nagretix vibrosov po formule (3):
   Formula 3:
               (A * M  * F * m * n * nu)
   C_m.p. =    -------------------------
                 2                 1/3
                H  * (V_1 * deltaT)


               (#{A} * #{@m7}  * #{F} * #{@m9} * #{$n_warm} * #{NU})
   C_m.p. =    ---------------------------------------------        = #{result}
                    2                 1/3
                #{H}  * (#{V_1} * #{DT})
PRINT

	result 

end
Cmr_warm();

# формула №21
def Vm_cold(_W0, _H)
	# W0 #формула11
	# H берётся из условия
	1.3 * W0 / H
end