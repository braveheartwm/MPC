function bounds=getbounds(S);
% GETBOUNDS Get a bounds on states and inputs of an MLD system
%
%  bounds=GETBOUNDS(S) get bounds xmin <= x<= xmax and umin <= u <= umax 
%  where the MLD system S is defined. The output argument bounds is a
%  structure with fields 'xmin','xmax','umin','umax'.
%
%(C) 2004 by Alberto Bemporad

xmin=S.xl';
xmax=S.xu';
umin=S.ul';
umax=S.uu';

% xmin=zeros(1,S.nx);
% xmax=zeros(1,S.nx);
% umin=zeros(1,S.nu);
% umax=zeros(1,S.nu);
% jx=0;
% ju=0;
% for i=1:length(S.symtable),
%     if S.symtable{i}.kind=='x',
%         jx=jx+1;
%         xmin(jx)=S.symtable{i}.min;
%         xmax(jx)=S.symtable{i}.max;
%     elseif S.symtable{i}.kind=='u',
%         ju=ju+1;
%         umin(ju)=S.symtable{i}.min;
%         umax(ju)=S.symtable{i}.max;
%     end        
% end

bounds=struct('xmin',xmin,'xmax',xmax,'umin',umin,'umax',umax);