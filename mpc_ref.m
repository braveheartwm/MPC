clear all;
close all;
clc;
G = tf(1, [1, 0.4,1])
step(G)
Gz = c2d(G,0.5)
[num,den] = tfdata(Gz)

[A,B,C,D] = tf2ss(num{1},den{1})