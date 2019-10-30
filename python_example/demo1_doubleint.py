import osqp
import numpy as np
import matplotlib.pyplot as plt
from scipy import sparse

# Define problem data
A = np.array([[1, 1],[0, 1]])
B = np.array([[0], [1]])
P = np.array([[1,0],[0,1]])
Q = np.array([[1,0],[0,0]])
R = np.array([0.1])
u_min = -1.0
u_max = 1.0
N = 2
Input_number = 1

r_size = R.shape[0]
q_size = Q.shape[0]
b_size = B.shape
R_bar = np.zeros([r_size*N, r_size*N])
Q_bar = np.zeros([q_size*N, q_size*N])

S_bar = np.zeros([b_size[0]*N, b_size[1]*N])
T_bar = np.zeros([b_size[0]*N, b_size[0]])

for i in range(N):
	R_bar[i*r_size:(i+1)*r_size,i*r_size:(i+1)*r_size] = R

	if i != N-1:
		Q_bar[(i)*q_size:(i+1)*q_size,(i)*q_size:(i+1)*q_size] = Q
	else:
		Q_bar[(i)*q_size:(i+1)*q_size,(i)*q_size:(i+1)*q_size] = P
	if i == 0:
		T_bar[i*b_size[0]:(i+1)*b_size[0],i*b_size[0]:(i+1)*b_size[0]] = A
		# S_bar[i*b_size[0]:(i+1)*b_size[0],0*b_size[1]:b_size[1]] = B
	else:
		T_bar[i*b_size[0]:(i+1)*b_size[0],0*b_size[0]:(1)*b_size[0]] = np.dot(
			T_bar[(i-1)*b_size[0]:i*b_size[0],(i-1)*b_size[0]:i*b_size[0]],A)
		# S_bar[i*b_size[0]:(i+1)*b_size[0],0*b_size[1]:b_size[1]] = np.dot(
		# 	A,S_bar[(i-1)*b_size[0]:(i)*b_size[0],0*b_size[1]:b_size[1]])
# print S_bar

for i in range(N):
	for j in range(i+1):
		if i == j:
			S_bar[i*b_size[0]:(i+1)*b_size[0],j*b_size[1]:(j+1)*b_size[1]] = B
		else:
			S_bar[i*b_size[0]:(i+1)*b_size[0],j*b_size[1]:(j+1)*b_size[1]] = np.dot(
			A,S_bar[(i-1)*b_size[0]:(i)*b_size[0],j*b_size[1]:(j+1)*b_size[1]])

print " "
H =  (R_bar +np.dot(np.dot(S_bar.transpose(),Q_bar),S_bar))*2
F = 2*np.dot(np.dot(T_bar.transpose(),Q_bar),S_bar).transpose()
Y = 2*(Q + np.dot(np.dot(T_bar.transpose(), Q_bar),T_bar))
G = np.zeros([2*N*Input_number,N*Input_number])
G[0:N*Input_number,0:N*Input_number]=np.eye(N*Input_number)
G[N*Input_number:2*N*Input_number,0:N*Input_number]=-np.eye(N*Input_number)

W = np.ones([2*N,1])*u_max
print W

X0 = np.zeros([2,1])
X0[0] = 10
# X0 = np.dot(A,X0) + np.dot(B,-1)
# print X0
status_x0 = []
status_x1 = []
U = []
T = 41
for t in range(T):
	status_x0.append(float(X0[0]))
	status_x1.append(float(X0[1]))
	P = sparse.csc_matrix(H)
	q = np.dot(X0.transpose(),F.transpose()).transpose()
	W = sparse.csc_matrix([[1,0],[1,0],[0,1]])
	l = np.array([-1-X0[1],-1,-1])
	u = np.array([float('inf'),1, 1])

	# Create an OSQP object
	prob = osqp.OSQP()

	# Setup workspace and change alpha parameter
	prob.setup(P, q, W, l, u, alpha=1.0)

	# Solve problem
	res = prob.solve()
	print res.x
	X0 = np.dot(A,X0) + np.dot(B,res.x[0])
	U.append(float(res.x[0]))
# print status_x0
ax1 = plt.subplot(2,1,1)
ax1.plot(range(T),status_x0,label='x0')
ax1.plot(range(T),status_x1,label='x1')
ax1.set_xlabel('time')
ax1.legend()
ax1.grid()

ax2 = plt.subplot(2,2,4)
ax2.plot(status_x0,status_x1)
ax2.plot(status_x0,status_x1,'d')
ax2.set_xlabel('x0')
ax2.set_ylabel('x1')
ax2.grid()

ax3 = plt.subplot(2,2,3)
ax3.plot(range(T),U,label = 'u')
ax3.set_xlabel('time')
ax3.legend()
ax3.grid()
plt.show()

