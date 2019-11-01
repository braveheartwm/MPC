import osqp
import numpy as np
import matplotlib.pyplot as plt
from scipy import sparse

A = np.array([[1.5968225, -0.8187308], [1.0, 0]])
B = np.array([[0.5], [0]])
C = np.array([[0.22936237,  0.2144542]])
# number of MV
nu = 1
# number of OV
ny = 1
# number of state
nx = 2
# predict horizon
N = 10
# min J
S = np.array([1])
T = np.array([0.04])

R_bar = np.zeros([nu*N, nu*N])
Q_bar = np.zeros([ny*N, ny*N])

A_aug = np.hstack((np.vstack((A, np.zeros([nu,nx]))),
        np.vstack((B, np.eye(nu)))))
B_aug = np.vstack((B, np.eye(nu)))
C_aug = np.hstack((C, np.zeros([ny,nu])))

S_bar = np.zeros([(nx+nu)*N, nu*N])
T_bar = np.zeros([(nx+nu)*N, (nx+nu)])

CS_bar = np.zeros([ny*N, nu*N])
CT_bar = np.zeros([ny*N, (nx+nu)])

for i in range(N):
    R_bar[i*nu:(i+1)*nu, i*nu:(i+1)*nu] = T
    Q_bar[i*ny:(i+1)*ny, i*ny:(i+1)*ny] = S
    if (i == 0):
        T_bar[i*(nx+nu):(i+1)*(nx+nu), 0:(nx+nu)] = A_aug
    else:
        T_bar[i*(nx+nu):(i+1)*(nx+nu), 0:(nx+nu)] = np.dot(
            A_aug, T_bar[(i-1)*(nx+nu):(i)*(nx+nu), 0:(nx+nu)])
    CT_bar[i*ny:(i+1)*ny, 0:(nx+nu)] = np.dot(
        C_aug, T_bar[i*(nx+nu):(i+1)*(nx+nu), 0:(nx+nu)])

for i in range(N):
    for j in range(i+1):
        # print i,j
        if i == j:
            S_bar[i*(nx+nu):(i+1)*(nx+nu), j*nu:(j+1)*nu] = B_aug
        else:
            S_bar[i*(nx+nu):(i+1)*(nx+nu), j*nu:(j+1)*nu] = np.dot(
                A_aug, S_bar[(i-1)*(nx+nu):(i)*(nx+nu), j*nu:(j+1)*nu])
        CS_bar[i*ny:(i+1)*ny, j*nu:(j+1)*nu] = np.dot(
            C, S_bar[i*nx:(i+1)*nx, j*nu:(j+1)*nu])

H = (np.dot(np.dot(CS_bar.transpose(), Q_bar), CS_bar) + R_bar)*2.0
F_tmp = 2.0*np.dot(CS_bar.transpose(), Q_bar)

np.set_printoptions(precision=3)

ts = 0.5
T = 10
n = int(T/ts+1)
# reference signal
Y_ref = np.ones([n, 1])
# l <= A_ineq * z <= u

x0 = np.array([[0.0], [0.0], [0.0]])
state_x0 = []
state_x1 = []
state_x2 = []
delta_U = np.zeros([nu, n])
# x0_aug = np.vstack((x0,delta_U[0:nu,0]))
U = np.zeros([nu,n])
y_rel = []
t = []
for i in range(n):
    t.append(i * ts)
plot_U = []
# print H
for i in range(n):
    A_ineq = np.eye(N)
    l = -0.2*np.ones([N,1])
    u = 0.2*np.ones([N,1])

    r = Y_ref[i]*np.ones([ny*N, 1])
    P = sparse.csc_matrix(H)
    q = np.dot(F_tmp, (np.dot(CT_bar, x0) - r))
    W = sparse.csc_matrix(A_ineq)
    
    # print A_ineq
    # Create an OSQP object
    prob = osqp.OSQP()

	# Setup workspace and change alpha parameter
    prob.setup(P, q, W, l, u, alpha=1.0)

	# Solve problem
    res = prob.solve()
    print "res=",res.x
    delta_U[0:nu,i] = res.x[0]

    if i == 0:
        U[0:nu,i] = delta_U[0:nu,i]
    else:
        U[0:nu,i] = U[0:nu,i-1] + delta_U[0:nu,i]
    plot_U.append(float(U[0:nu,i]))
    x_tmp = np.dot(A,x0[0:2]) + np.dot(B,float(U[0:nu,i]))
    x0 = np.dot(A_aug,x0) + np.dot(B_aug,float(delta_U[0:nu,i]))
    y_rel.append(float(np.dot(C_aug,x0)))
    state_x0.append(x0[0])
    state_x1.append(x0[1])
    state_x2.append(x0[2])
    pass

ax1 = plt.subplot(2,1,1)
ax1.plot(t,y_rel,label='y')
ax1.plot(t,Y_ref,label='reference')
ax1.set_xlabel('time')
ax1.legend()
ax1.grid()

ax2 = plt.subplot(2,1,2)
ax2.step(t,plot_U,label='input')
ax2.set_xlabel('time')
ax2.legend()
ax2.grid()
plt.show()

