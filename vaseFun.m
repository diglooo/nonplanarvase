function retval=vaseFun(t,lobes)

retval=[(10+sqrt(t)*2)*cos(2*pi*t), (10+sqrt(t)*2)*sin(2*pi*t), (t+(0.2*exp(t/50))*cos(lobes*2*pi*t))*0.2];
end