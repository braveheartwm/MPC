function [xmin,fmin,QPcter,flag] = miqp3_naf(Q,  b, C, d, ivar, deci, ...
    VLB, VUB, x0, iprint, tolerances,solver)
%MIQP3_NAF Solve a mixed-integer quadratic or linear program
%
%[xmin,fmin,QPcter,flag] = miqp3_naf(Q,  b, C, d, ivar, deci, ...
%                                             VLB, VUB, x0, iprint, tolerances,solver)
%
% Parameters:
%   input:      Q,b : parameters of the cost function
%               C,d : parameters defining the constraints
%               ivar: vector of indices of the integer variables
%               deci: parameter denoting the decision about the branching
%                     strategy and node selection rule
%                        0: first free variable is chosen, depth first
%                        1: free variable with max frac part is chosen, depth first
%		       				10: the order how the problems are put onto the
% 			   					 stack is reversed, otherwise like '0'
%		       				11: the order how the problems are put onto the
% 			   					 stack is reversed, otherwise like '1'
%                    [z,0]: same as option [z] (depth first)
%                    [z,1]: same as option [z], but breadth first
%                    [z,2]: same as option [z], but best first
%                    [z,3]: same as option [z], but best first with normalized cost
%               VLB:  lower bounds on x
%               VUB:  upper bounds on x
%               x0:   initial condition
%               iprint: verbosity (1=verbose, 0=silent)
%               tolerances:tolerances(1) ->large positive number for infinity
%                                      default = 1e10
%                                      used for:
%                                      - box bounds defaults
%                                      - initialization of value function
%                                      - minus infinity for unbounded cost
%                                      - infinity in e04naf
%                     tolerances(2) -> large positive number
%                                      default  = 1e5
%                                      used for:
%                                      - lower bounds on Ax in e04naf
%                     tolerances(3) -> small positive number
%                                      default  = 1e-10
%                                      used for:
%                                      - determination, whether Q is empty, so
%                                        the problem can be treated as MILP
%                     tolerances(4) -> small positive number
%                                      default  = 1e-4
%                                      used for:
%                                      - determination, whether a solution is
%                                        integer
%                     tolerances(5) -> maximum number of QP iteration in e04naf
%                                      default  = 50
%               solver: either 'matlab' (use QP.M) or 'nag' (use NAG Foundation Toolbox)
%
%   output:     xmin: minimizer of the quadratic cost function
%               fmin: minimum value of the cost function
%               QPcter: number of QP executed
%               flag: integer flag characterizing the result, where:
%                     if flag = 1 there exists a feasible solution
%                     if flag = 5 the solution is not integer feasible
%                     if flag = 7 no feasible solution exists
%                     if flag = -1 the solution is unbounded
%
% Description:
% ------------
% Solves the following Mixed Integer Quadratic Program
%
% min         0.5*x'Q x + b' x
% subject to  Cx <= d
%
% If VLB, VUB are supplied, then the additional constraint
%
%             VLB <= x <= VUB
%
% is imposed. If x0 is supplied, then x0 is taken as initial condition
%
% The variables indexed by ivar are integers
%
% The original problem is relaxed and decomposed into subproblems that
% are put onto a stack. Each subproblem is stored as data record with
% 11 fields:
% Q,b:  parameters of the subproblem cost function
% C,d:  parameters of the subproblem constraints
% e:    constant term in the optimization (used to evaluate cost)
% VLB,VUB: parameters of the subproblem upper/lower bounds
% x0:   initial condition of the subproblem
% ivar: vector of indices of free integer variables
% ivalues: values of integer variables {0,1,-1}    (-1=free)

%(C) 2003-2008 by A. Bemporad, D. Mignone

% Some argument verifications

error(nargchk(4,12,nargin));

if nargin<11,
    solver='nag';
end

if nargin <= 10
    % verybig  constant representing "infinity"
    % big      a big number
    verybig   = 1e10;
    big       = 1e6;
    verysmall = 1e-10;
    integereps= 1e-4;
    itmax     = 250;
else
    if length(tolerances) < 5
        verybig   = 1e10;        % take defaults
        big       = 1e4;
        verysmall = 1e-10;
        integereps= 1e-4;
        itmax     = 50;
    else
        verybig   = tolerances(1);
        big       = tolerances(2);
        verysmall = tolerances(3);
        integereps= tolerances(4);
        itmax     = tolerances(5);
    end
end
if nargin<=9,
    iprint=0;
end
if isempty(iprint),
    iprint=0;
end
if size(Q,1) ~= size(Q,2)
    error('Q is not square')
end

if Q==zeros(size(Q,1))
    if iprint>=1
        warning('This is a MILP')
    end
elseif ~(max(max(abs(Q-Q'))) <= eps^(2/3)*max(max(abs(Q)))),
    Q=0.5*(Q+Q');
    warning('Q is not symmetric: replaced by its symmetric part')
end

if (size(b,1) ~= 1) & (size(b,2) ~= 1)
    error('b must be a vector')
end

if size(b,2) ~= 1
    % b is a column vector
    b = b';
end

if size(C,1) ~= size(d,1)
    error('C and d have incompatible dimensions')
end

nx=size(Q,1);
if nargin<=8,
    x0=[];
    if nargin<=7,
        VUB=[];
        if nargin<=6,
            VLB=[];
            if nargin<=5,
                deci=1;
                if nargin<=4,
                    ivar=[];
                end
            end
        end
    end
end

VLB  = VLB(:);
VUB  = VUB(:);
x0   = x0(:);
ivar = ivar(:);              %Indices of integer variables

if size(VLB,1)~=nx & ~isempty(VLB)
    error('VLB has wrong dimensions')
end
if size(VUB,1)~=nx & ~isempty(VUB)
    error('VUB has wrong dimensions')
end
if size(x0,1)~=nx & ~isempty(x0)
    error('x0 has wrong dimensions')
end

cont=(1:nx)';
cont(ivar)=[];               %Indices of continuous variables

%ivar = sort(ivar);  % may not be required %


% zstar    denotes the best value for the cost function so far
% qpconter counts how many times the qp algorithm is invoked
% nivar    is the total number of integer variables
% xstar    denotes the current optimal vector

zstar     = verybig;
xstar     = zeros(nx,1);
qpcounter = 0;
nivar     = length(ivar);
flag      = 7; % by default it is infeasible

% Initialize parameters for the QP routine
cold      = 1;
wu        = sqrt(eps);
orthog    = 1;

if length(deci)>1,
    nodesel=deci(2);
    deci=deci(1);
else
    nodesel=0; % Default if depth-first
end

% Define default values for VLB,VUB,x0
if isempty(VLB),
    VLB=-2*verybig*ones(nx,1);
end
if isempty(VUB),
    VUB=2*verybig*ones(nx,1);
end
if isempty(x0),
    x0=zeros(nx,1);
end

% checking whether the bounds 0,1 on the binary variables are already present in
% the problem constraints, if not, add them

aux1	     = VLB(ivar);
index1       = find(aux1<0);
aux1(index1) = 0;
VLB(ivar)    = aux1;

aux2	     = VUB(ivar);
index2       = find(aux2>1);
aux2(index2) = 1;
VUB(ivar)    = aux2;

% The Variable STACK will contain the subproblems that are generated
% during the MIQP. It's global to allow the subroutines at the end of
% the m-file to access it. STACKSIZE denotes the number of subprobems
% on the stack.

global STACK
global STACKSIZE
global STACKCOST
global STACKPOINTER

% Initialization of STACK with the MIQP

STACKSIZE = 1;
STACK     = struct('Q',Q, 'b',b, 'C',C, 'd',d, 'e', 0, 'VLB',VLB, ...
    'VUB', VUB, 'x0', x0, 'ivar',ivar, 'ivalues',-ones(nivar,1),'level',0);
STACKCOST = 0; % Array storing the cost of the father problem, ordered in decreasing
% fashion (STACKCOST(1)=largest value)
STACKPOINTER = 1; % Now STACK is a unordered list, and STACKPOINTER stores the order
% of the list.

if strcmp(solver,'nag'),
    persistent cwsav lwsav iwsav rwsav nagver % needed for NAG toolbox for M7
    if isempty(cwsav),
        try
            nagver=7;
            [cwsav,lwsav,iwsav,rwsav,ifail] = e04wb('e04nf');
        catch
            nagver=6;
        end
    end
end

% Main Loop

while (STACKSIZE>0)

    % Get the next subproblem from the STACK
    subprob = pop;

    % Solve the qp
    if size(subprob.Q,1)>0
        if norm(subprob.Q,inf) < verysmall
            lp = 1;
        else
            lp = 0;
        end;

        if strcmp(solver,'nag'),

            bl     = [subprob.VLB; -big*ones(length(subprob.d),1)];
            bu     = [subprob.VUB;  subprob.d];

            if nagver==6,
                % NAG for M6
                istate = zeros(length(bu),1);
                featol = wu*ones(length(bu),1);
                ifail  = 1;
                [x,iter,obj,clamda,istate,ifail] = ...
                    e04naf(bl, bu, 'qphess', subprob.x0, subprob.b, subprob.C, ...
                    subprob.Q, lp, cold, istate, featol, iprint, itmax, verybig, ...
                    orthog, ifail);
                switch ifail
                    case {0,1,3}
                        how = 'ok';
                    case 2
                        how = 'unbounded';
                    case {4,5}
                        % might also be considered as infeasible %
                        warning('QP is cycling or too few iterations')
                        how = 'ok';
                    case {6,7,8}
                        how = 'infeasible';
                    otherwise
                        error('other error code in "ifail" from e04naf')
                end
            else
                % NAG for M7
                istate=zeros(sum(size(subprob.C)), 1, 'int32'); % Default: cold start

                evalc(['[istate,x,iter,obj,ax,clamda,user,lwsavOut,iwsavOut,rwsavOut,ifail]=e04nf(' ...
                    'subprob.C,bl,bu,subprob.b,subprob.Q,''e54nfu'',istate,subprob.x0,lwsav,iwsav,rwsav);']);

                %clamda=-clamda(n+1:n+q);

                switch ifail
                    case {0,1}
                        how = 'ok';
                    case 2
                        how = 'unbounded';
                    case 3
                        how = 'infeasible';
                    case 4
                        % might also be considered as infeasible %
                        %warning('QP is cycling or too few iterations')
                        how = 'infeasible';
                    case {5}
                        error('An input parameter in E04BMF is invalid.');
                    otherwise
                        error('other error code in "ifail" from E04MBF')
                end
            end
        else
            swarn=warning;
            warning off;
            [x,lam,how]=qpsol(subprob.Q, subprob.b, subprob.C, subprob.d, ...
                subprob.VLB,subprob.VUB, subprob.x0,5,[],iprint-1);
            warning swarn

        end
        qpcounter = qpcounter + 1;

    else
        x=[];
        if all(subprob.d>=0),
            how='ok';
        else
            how='infeasible';
        end
    end
    if strcmp(how,'unbounded')
        % If the relaxed problem is unbounded, so is the original
        % problem: Formal proof pending
        xmin = [];
        fmin = -verybig;
        flag = -1;
        warning('unbounded cost function')
        return
    elseif strcmp(how,'infeasible')
        % subproblem fathomed
    else
        % subproblem feasible

        if ~isempty(x),
            zpi=.5*x'*subprob.Q*x+x'*subprob.b+subprob.e;
        else
            zpi=subprob.e;
        end
        if flag~=1,
            flag=5;
        end

        % Check if value function is better than the value so far
        if (zpi<=zstar)

            % Test whether the relaxed integer variables are feasible,
            % i.e. whether they are integral. Note that this condition
            % is always satisfied, if there are no free integer va-
            % riables, i.e if ivar is empty

            xi=x(subprob.ivar); %integer variables
            xc=x;xc(subprob.ivar)=[];    %continuous variables

            if norm( round(xi) - xi,inf) < integereps
                % subproblem solved
                % update the value of the cost function
                zstar = zpi;
                ifree=find(subprob.ivalues==-1);
                iset=find(subprob.ivalues>-1);
                absi=1:nx;
                absi(cont) = [];
                xstar(absi(ifree))=xi;
                xstar(absi(iset))=subprob.ivalues(iset);
                xstar(cont)=xc;
                flag=1;
            else
                % separate subproblem, if there are still free integer
                % variables. Note that no further test is required,
                % whether there are still integer variables, since ixrel
                % is nonempty
                % branchvar denotes the position of the branching
                %           integer variable within the set of integer
                %           variables in the present subproblem
                branchvar           = decision(x,subprob.ivar,deci);
                [p0,p1,zeroOK,oneOK] = separate(subprob,branchvar);
                switch nodesel
                    case 0
                        cost=1/(subprob.level+1); % Depth first
                    case 1
                        cost=subprob.level+1; % Breadth first
                    case 2
                        cost=zpi; % Best-first. This tends to go breadth-first
                    case 3
                        cost=zpi/(subprob.level+1); % This privilegiates deep nodes
                end
                if deci >= 10
                    if oneOK
                        hh=push(p1,cost);
                    end
                    if zeroOK
                        push(p0,cost,hh+1);
                    end
                else
                    if zeroOK
                        hh=push(p0,cost);
                    end
                    if oneOK
                        push(p1,cost,hh+1);
                    end
                end  %if deci ... %
            end  %if norm ... %
        end  %if (zpi<=zpstar) %
    end  %if strcmp ...%


    % Display present status of the MIQP
    if (flag > 0) & (iprint > 0)
        disp('qpcounter =') , disp(qpcounter)
        disp('zstar     =') , disp(zstar)
        disp('xstar     =') , disp(xstar')
    end

end  %while%


% Display final results

xmin = xstar;
%xmin(ivar)=round(xstar(ivar)); % ROUNDOFF integer solution!!

fmin = zstar;
QPcter = qpcounter;

% ---------------------------------------------------------------------
% Subroutines
% ---------------------------------------------------------------------

% push: puts a subproblem onto the STACK and increases the STACKSIZE
%       input:  record containing the subproblem
%       output: none
%       modifies global variables

function j=push(element,cost,i)
global STACK
global STACKSIZE
global STACKCOST
global STACKPOINTER

% Determine position in STACK where problem is inserted, according to a best first
% strategy

if nargin<3,
    ii=find(STACKCOST>cost);  % EX: STACKCOST=[100 80 33 22 ^ 5 3 2], cost=10
    if ~isempty(ii),
        i=ii(end);
    else
        i=0;
    end
end
STACKSIZE=STACKSIZE+1;
STACKPOINTER=[STACKPOINTER(1:i);STACKSIZE;STACKPOINTER(i+1:end)];
STACKCOST=[STACKCOST(1:i);cost;STACKCOST(i+1:end)];
STACK(STACKSIZE) = element;

j=i; % Can be used to push other brother problems

% pop: returns top element of the STACK and decreases the STACKSIZE,
%      eliminating the element from the stack
%      input:  none
%      output: record containing the top-subproblem
%      modifies global variables

function subprob = pop
global STACK
global STACKSIZE
global STACKCOST
global STACKPOINTER

i=STACKPOINTER(end);
subprob   = STACK(i);
STACKSIZE = STACKSIZE-1;
STACKPOINTER(end)=[];
STACKCOST(end)=[];


% separate: generates 2 new suproblems from a given problem by
%           branching on an arbitrary variable
%           input:  prob=problem to separate
%                   branchvar=branching variable index. The variable
%                   is x(ivar(branchvar)) in the coordinates of the subproblem
%           output: the 2 subproblems in record format
%                 zeroOK,    if set to one, this flags denote that setting
%                 oneOK:     the current branching variable to zero (to one)
%                            is compatible with the box constraints VLB and VUB
%                            of the current relaxed QP. If set to zero, these
%                            flags denote that the correponding problem should
%                            not be pushed onto the stack, since it is
%                            infeasible in terms of the original constraints

function [p0,p1,zeroOK,oneOK] = separate(prob,branchvar)
if (length(prob.ivar) >= 1)
    nx    = size(prob.Q,1);
    this  = prob.ivar(branchvar);
    others= [1:this-1,this+1:nx];

    % extract the values of the box bounds for the binary branching variable
    % this is used, to check, whether there are box bounds that do not allow
    % to set one variable to a particular value

    lbbranch = prob.VLB(this);
    ubbranch = prob.VUB(this);

    if (lbbranch <= 0) & (ubbranch >= 0)
        zeroOK = 1;
    else
        zeroOK = 0;
    end

    if (lbbranch <= 1) & (ubbranch >= 1)
        oneOK = 1;
    else
        oneOK = 0;
    end

    if (zeroOK == 0) & (oneOK == 0)
        error('box constraints on the binary variables are infeasible')
    end

    % Generate new Q
    % Partition old Q into 4 blocks, some of which are possibly empty
    % Note that the old Q itself is not empty

    Q11 = prob.Q(others,others);
    Q12 = prob.Q(others,this);
    Q22 = prob.Q(this,this);

    p0.Q=Q11;
    p1.Q=Q11;

    % Generate new b
    % Partition old b into 2 blocks, some of which are possibly empty
    % Note that a contribution from the partitioning of Q is present

    b1  = prob.b(others);
    b2  = prob.b(this);

    p0.b=b1;
    p1.b=b1(:)+Q12(:);

    % Generate new C
    % Partition old C into 3 blocks, some of which are possibly empty

    C  = prob.C(:,others);

    p0.C=C;
    p1.C=C;

    % Generate new d
    % The only modification is a contribution from the matrix C

    p0.d = prob.d;
    p1.d = prob.d - prob.C(:,this);

    % Generate new e
    % The only modification is a contribution from Q22, b2

    p0.e = prob.e;
    p1.e = prob.e+ .5*Q22 + b2;

    % Generate new VLB,VUB,x0

    if ~isempty(prob.VLB),
        VLB=prob.VLB(others);
    else
        VLB=[];
    end
    p0.VLB=VLB;
    p1.VLB=VLB;

    if ~isempty(prob.VUB),
        VUB=prob.VUB(others);
    else
        VUB=[];
    end
    p0.VUB=VUB;
    p1.VUB=VUB;

    if ~isempty(prob.x0),
        x0=prob.x0(others);
    else
        x0=[];
    end
    p0.x0=x0;
    p1.x0=x0;

    % Generate new ivar

    %EX:              1 2 3 4 5 6 7 8 9
    %       old_ivar=[    3 4 5     8]'
    %       branchvar=5
    %       newivar= [    3 4     7]'

    ivar=[prob.ivar(1:branchvar-1);prob.ivar(branchvar+1:length(prob.ivar))-1];

    % Collect the terms for the new subproblems

    p0.ivar = ivar;
    p1.ivar = ivar;

    %Find the absolute index of the branching variable
    ifree=find(prob.ivalues==-1); %Collect free integer variables
    ibranch=ifree(branchvar);     %Pick up the branch variable

    aux         = prob.ivalues;
    aux(ibranch)= 0;
    p0.ivalues  = aux;
    aux(ibranch)= 1;
    p1.ivalues  = aux;

    p0.level=prob.level+1;
    p1.level=prob.level+1;


else
    error('no more integer variables to branch on')
end


% decision: when a problem has to be separated, this function decides
%           which will be the next branching variable
%           input: x    = present value of the solution of the qp
%                  ivar = indices of the free integer variables relative to x
%                  d    = parameter denoting the decison strategy that has to
%                         be adopted
%          output: branchvar = next branching variable position within ivar

function branchvar = decision(x,ivar,d);
switch d
    case {0,10}
        % first free variable is chosen as branching variable
        branchvar=1;
    case {1,11}
        % integer free variable with max frac part is
        % chosen as branching variable
        xi=x(ivar);
        [aux1,aux2]=max(abs(xi-round(xi)));
        branchvar=aux2(1); %pick up the first of with max value
    otherwise
        % decision not implemented
        warning('decision not implemented: switch to "first free"');
        branchvar=1;
end
