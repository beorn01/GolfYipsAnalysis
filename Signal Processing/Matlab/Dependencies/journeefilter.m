function pf=journeefilter(p,hpfreq,lpfreq,sampfreq)
%hpfreq usually 0.1 Hz
%lpfreq usually 5 Hz
%function to perform a journee filter
deltat=1/sampfreq;
butorder=4;
[num1,den1]=butter(butorder,hpfreq/(sampfreq/2));%lowpass filter, 5th order
[num2,den2]=butter(butorder,lpfreq/(sampfreq/2));%lowpass filter butterworth, 5th order
%first high pass filtering on a very low frequency to remove drift and
%motion artifacts
if (length(p)>15)
    pf1=p-filtfilt(num1,den1,p);
    pf=filtfilt(num2,den2,abs(pf1));
else
    pf=p;
end
%next absolute value
%next low pass filtering to remove action potentials from the emg and
%obtain convolutes
