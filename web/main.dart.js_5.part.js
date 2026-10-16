((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,E,G,I,K,C={
bpD(d){var w,v,u,t,s,r,q=J.a8(d)
q.h(d,"total_deliveries")
q.h(d,"completed_deliveries")
w=q.h(d,"total_earnings")
if(w==null)w=0
if(q.h(d,"avg_earning_per_delivery")==null)q.h(d,"average_earning_per_delivery")
v=q.h(d,"today_earnings")
if(v==null)v=0
u=q.h(d,"today_deliveries")
if(u==null)u=0
t=q.h(d,"week_earnings")
if(t==null)t=0
s=q.h(d,"month_earnings")
if(s==null)s=0
r=A.cz(q.h(d,"average_rating"))
if(r==null)r=null
q=q.h(d,"recent_deliveries")
if(q==null)q=[]
q=J.ei(x.j.a(q),new C.aCp(),x.L)
q=A.ah(q,q.$ti.i("aO.E"))
return new C.aCo(w,v,u,t,s,r,q)},
t4:function t4(d,e,f,g){var _=this
_.a=d
_.b=e
_.d=f
_.e=g},
aCo:function aCo(d,e,f,g,h,i,j){var _=this
_.c=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j},
aCp:function aCp(){},
bD9(){return new C.t3(null)},
t3:function t3(d){this.a=d},
acZ:function acZ(){this.d=0
this.c=this.a=null},
b7E:function b7E(d){this.a=d},
b7D:function b7D(d,e){this.a=d
this.b=e},
NB:function NB(d){this.a=d},
NC:function NC(d){var _=this
_.d=d
_.f=_.e=!0
_.w=_.r=null
_.x=""
_.y=null
_.z=0
_.c=_.a=null},
aM1:function aM1(d,e){this.a=d
this.b=e},
aM7:function aM7(d,e){this.a=d
this.b=e},
aM8:function aM8(d,e){this.a=d
this.b=e},
aM0:function aM0(d,e){this.a=d
this.b=e},
aMc:function aMc(d){this.a=d},
aMd:function aMd(){},
aM2:function aM2(d){this.a=d},
aM3:function aM3(d,e){this.a=d
this.b=e},
aM4:function aM4(d,e){this.a=d
this.b=e},
aM5:function aM5(d){this.a=d},
aM6:function aM6(d,e){this.a=d
this.b=e},
aLY:function aLY(d,e){this.a=d
this.b=e},
aLX:function aLX(d){this.a=d},
aMa:function aMa(d){this.a=d},
aM9:function aM9(d,e){this.a=d
this.b=e},
aMb:function aMb(d){this.a=d},
aLZ:function aLZ(d,e){this.a=d
this.b=e},
aM_:function aM_(d,e){this.a=d
this.b=e},
Qo:function Qo(d){this.a=d},
Qp:function Qp(d,e,f){var _=this
_.d=d
_.e=!0
_.f=""
_.dJ$=e
_.hU$=f
_.c=_.a=null},
aZV:function aZV(d){this.a=d},
aZH:function aZH(d){this.a=d},
aZI:function aZI(d,e){this.a=d
this.b=e},
aZJ:function aZJ(d,e){this.a=d
this.b=e},
aZK:function aZK(d){this.a=d},
aZS:function aZS(d){this.a=d},
aZQ:function aZQ(d){this.a=d},
aZR:function aZR(d){this.a=d},
aZT:function aZT(d,e){this.a=d
this.b=e},
aZP:function aZP(d){this.a=d},
aZG:function aZG(d,e,f){this.a=d
this.b=e
this.c=f},
aZF:function aZF(d,e,f){this.a=d
this.b=e
this.c=f},
aZE:function aZE(d){this.a=d},
aZU:function aZU(d){this.a=d},
aZL:function aZL(d,e){this.a=d
this.b=e},
aZM:function aZM(d,e){this.a=d
this.b=e},
aZN:function aZN(d,e){this.a=d
this.b=e},
aZO:function aZO(d,e){this.a=d
this.b=e},
Sm:function Sm(d){this.a=d},
Sn:function Sn(){var _=this
_.e=_.d=null
_.f=!0
_.c=_.a=null},
b7M:function b7M(d){this.a=d},
b7N:function b7N(d,e){this.a=d
this.b=e},
b7O:function b7O(d,e){this.a=d
this.b=e},
b7P:function b7P(d){this.a=d},
ad0:function ad0(d){this.a=d},
b8n:function b8n(d){this.a=d},
agD:function agD(){},
Wb(d){var w=0,v=A.q(x.l),u,t,s
var $async$Wb=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bZ("GET",A.as("https://findfooddelivery-backend.onrender.com/deliveries/available",0,null),A.Q(["Authorization","Bearer "+d],t,t)),$async$Wb)
case 3:s=f
t=s.b
if(t===200){t=J.ei(A.fa(s),new C.ajN(),x.W)
t=A.ah(t,t.$ti.i("aO.E"))
u=t
w=1
break}throw A.h(A.ag("Failed to load deliveries ("+t+")"))
case 1:return A.o(u,v)}})
return A.p($async$Wb,v)},
Wm(d){var w=0,v=A.q(x.P),u,t,s,r
var $async$Wm=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bZ("GET",A.as("https://findfooddelivery-backend.onrender.com/riders/me/analytics",0,null),A.Q(["Authorization","Bearer "+d],t,t)),$async$Wm)
case 3:s=f
r=A.bi(s)
if(s.b===200){u=r
w=1
break}t=J.C(r,"detail")
throw A.h(A.ag(t==null?"Failed to load analytics":t))
case 1:return A.o(u,v)}})
return A.p($async$Wm,v)},
Wv(d,e){var w=0,v=A.q(x.H),u,t
var $async$Wv=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.j($.aH().bk("PUT",A.as("https://findfooddelivery-backend.onrender.com/riders/me/online",0,null),A.Q(["Content-Type","application/json","Authorization","Bearer "+d],u,u),B.U.bS(A.Q(["online",e],u,x.y),null),null),$async$Wv)
case 2:t=g
if(t.b!==200)throw A.h(A.ag(A.br(t,"Could not change your status")))
return A.o(null,v)}})
return A.p($async$Wv,v)},
ajQ(d){var w=0,v=A.q(x.D),u,t,s
var $async$ajQ=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bZ("GET",A.as("https://findfooddelivery-backend.onrender.com/deliveries/offers",0,null),A.Q(["Authorization","Bearer "+d],t,t)),$async$ajQ)
case 3:s=f
if(s.b===200){u=A.dS(A.fa(s),!0,x.P)
w=1
break}throw A.h(A.ag(A.br(s,"Could not load requests")))
case 1:return A.o(u,v)}})
return A.p($async$ajQ,v)},
ajg(d,e){var w=0,v=A.q(x.W),u,t,s
var $async$ajg=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bk("POST",A.as(y.a+e+"/accept",0,null),A.Q(["Authorization","Bearer "+d],t,t),null,null),$async$ajg)
case 3:s=g
if(s.b===200){u=A.B0(A.bi(s))
w=1
break}throw A.h(A.ag(A.br(s,"Could not accept the delivery")))
case 1:return A.o(u,v)}})
return A.p($async$ajg,v)},
ajv(d,e){var w=0,v=A.q(x.H),u,t
var $async$ajv=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.j($.aH().bk("POST",A.as(y.a+e+"/decline",0,null),A.Q(["Authorization","Bearer "+d],u,u),null,null),$async$ajv)
case 2:t=g
if(t.b!==200)throw A.h(A.ag(A.br(t,"Could not decline")))
return A.o(null,v)}})
return A.p($async$ajv,v)},
Wn(d){var w=0,v=A.q(x.P),u,t,s
var $async$Wn=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bZ("GET",A.as(y.d,0,null),A.Q(["Authorization","Bearer "+d],t,t)),$async$Wn)
case 3:s=f
if(s.b===200){u=A.bi(s)
w=1
break}throw A.h(A.ag(A.br(s,"Could not load your verification")))
case 1:return A.o(u,v)}})
return A.p($async$Wn,v)},
akZ(d,e){var w=0,v=A.q(x.P),u,t,s
var $async$akZ=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.j($.aH().bk("PUT",A.as(y.d,0,null),A.Q(["Content-Type","application/json","Authorization","Bearer "+d],t,t),B.U.bS(e,null),null),$async$akZ)
case 3:s=g
if(s.b===200){u=A.bi(s)
w=1
break}throw A.h(A.ag(A.br(s,"Could not send your details")))
case 1:return A.o(u,v)}})
return A.p($async$akZ,v)},
ajN:function ajN(){},
L1:function L1(d,e){this.c=d
this.a=e},
So:function So(d,e,f){var _=this
_.d=d
_.e=null
_.f=-1
_.dJ$=e
_.hU$=f
_.c=_.a=null},
b7S:function b7S(d,e){this.a=d
this.b=e},
b7Q:function b7Q(d,e){this.a=d
this.b=e},
b7R:function b7R(d){this.a=d},
b7T:function b7T(d,e){this.a=d
this.b=e},
aai:function aai(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
b_r:function b_r(){},
b_s:function b_s(d,e){this.a=d
this.b=e},
b_q:function b_q(d){this.a=d},
b_t:function b_t(d){this.a=d},
b_u:function b_u(d){this.a=d},
aha:function aha(){},
L3:function L3(d){this.a=d},
Sp:function Sp(){this.c=this.a=this.d=null},
b7X:function b7X(d,e){this.a=d
this.b=e},
L4:function L4(d,e,f){this.c=d
this.d=e
this.a=f},
Sv:function Sv(d,e,f,g,h){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x="motorbike"
_.y=!1
_.c=_.a=null},
b8o:function b8o(d){this.a=d},
b8p:function b8p(d){this.a=d},
b8r:function b8r(){},
b8u:function b8u(d,e,f){this.a=d
this.b=e
this.c=f},
b8s:function b8s(d,e){this.a=d
this.b=e},
b8t:function b8t(d,e){this.a=d
this.b=e},
b8q:function b8q(d,e){this.a=d
this.b=e},
D1:function D1(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
brW(d,e,f,g){var w,v,u,t,s,r,q,p,o,n=null,m=e.length,l="",k=n
if(m!==0){v=0
for(;;){if(!(v<m)){w=0
break}if(e.charCodeAt(v)===64){l=B.d.ae(e,0,v)
w=v+1
break}++v}if(w<m&&e.charCodeAt(w)===91){for(u=w,t=-1;u<m;++u){s=e.charCodeAt(u)
if(s===37&&t<0){r=B.d.ea(e,"25",u+1)?u+2:u
t=u
u=r}else if(s===93)break}if(u===m)throw A.h(A.cZ("Invalid IPv6 host entry.",e,w))
q=t<0?u:t
A.bqC(e,w+1,q);++u
if(u!==m&&e.charCodeAt(u)!==58)throw A.h(A.cZ("Invalid end of authority",e,u))}else u=w
for(;u<m;++u)if(e.charCodeAt(u)===58){p=B.d.c9(e,u+1)
k=p.length!==0?A.fE(p,n):n
break}o=B.d.ae(e,w,u)}else o=n
return A.iB(n,o,n,A.a(f.split("/"),x.s),k,g,d,l)}},D,H,F
J=c[1]
A=c[0]
B=c[2]
E=c[8]
G=c[16]
I=c[9]
K=c[13]
C=a.updateHolder(c[4],C)
D=c[17]
H=c[7]
F=c[11]
C.t4.prototype={}
C.aCo.prototype={}
C.t3.prototype={
L(){return new C.acZ()}}
C.acZ.prototype={
t(d){var w=null,v=this.d
return A.de(w,w,new A.qX([D.arJ,D.at6,D.atq,D.ats][v],w),A.asb(0,w,w,v,D.a1H,w,new C.b7E(this)),w,!0,w,w)}}
C.NB.prototype={
L(){return new C.NC(A.a([],x.A))}}
C.NC.prototype={
Gi(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$Gi=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=r.c
m.toString
q=A.af(m,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.j(C.Wn(q),$async$Gi)
case 7:p=e
if(r.c==null){w=1
break}m=r.w
o=J.f(m==null?null:J.C(m,"can_work"),!1)
r.n(new C.aM1(r,p))
if(o&&J.f(J.C(p,"can_work"),!0))r.j0()
t=2
w=6
break
case 4:t=3
l=s.pop()
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Gi,v)},
Hz(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$Hz=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=!r.f
r.n(new C.aM7(r,m))
o=r.c
o.toString
q=A.af(o,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.j(C.Wv(q,m),$async$Hz)
case 7:t=2
w=6
break
case 4:t=3
l=s.pop()
p=A.a5(l)
if(r.c==null){w=1
break}r.n(new C.aM8(r,m))
r.c.U(x.q).f.bO(A.d7(null,null,null,null,null,B.B,null,A.i(A.b8(p),null,null,null,null,null,null,null,null,null),null,B.ae,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Hz,v)},
Gh(d){return this.ayc(d)},
ayc(d){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p
var $async$Gh=A.m(function(e,f){if(e===1){t.push(f)
w=u}for(;;)switch(w){case 0:u=3
w=6
return A.j(C.Wm(d),$async$Gh)
case 6:r=f
if(s.c!=null)s.n(new C.aM0(s,r))
u=1
w=5
break
case 3:u=2
p=t.pop()
w=5
break
case 2:w=1
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$Gh,v)},
nS(d){return this.aAd(d)},
aAd(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$nS=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.l(s)+","+A.l(d.as):d.z
if(r==null||B.d.a2(r).length===0){t.c.U(x.q).f.bO(D.Id)
w=1
break}w=3
return A.j(A.ug(C.brW("https","www.google.com","/maps/dir/",A.Q(["api","1","destination",r],x.N,x.z)).git(),B.lR,null),$async$nS)
case 3:if(!f&&t.c!=null)t.c.U(x.q).f.bO(D.Ic)
case 1:return A.o(u,v)}})
return A.p($async$nS,v)},
Z(){var w,v,u=this
u.ab()
u.j0()
u.Gi()
u.y=A.li(B.ox,new C.aMc(u))
w=u.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)C.Wv(v,!0).dS(new C.aMd())},
j(){var w=this.y
if(w!=null)w.av(0)
this.a6()},
j0(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j0=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d)
if(p.c==null){w=1
break}q.n(new C.aM2(q))
l=p.c
l.toString
q.Gh(l)
t=4
l=p.c
l.toString
w=7
return A.j(C.Wb(l),$async$j0)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.n(new C.aM3(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a5(k)
if(q.c==null){r=[1]
w=5
break}q.n(new C.aM4(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.n(new C.aM5(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j0,v)},
GF(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$GF=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(!r.f){w=1
break}o=r.c
o.toString
q=A.af(o,!1,x.d)
if(q.c==null){w=1
break}t=4
o=q.c
o.toString
w=7
return A.j(C.Wb(o),$async$GF)
case 7:p=e
if(r.c==null){w=1
break}if(J.b9(p)>r.z)r.c.U(x.q).f.bO(A.d7(null,null,null,B.m,B.df,B.B,null,D.a9i,null,B.ae,null,null,null,B.ba,null,null,null,new A.bG(A.a_(12),B.L),null,null))
r.n(new C.aM6(r,p))
t=2
w=6
break
case 4:t=3
m=s.pop()
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$GF,v)},
EI(d){return this.alx(d)},
alx(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l,k,j
var $async$EI=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=r.c
k.toString
q=A.af(k,!1,x.d)
t=4
k=q.c
k.toString
n=""+d.a
w=7
return A.j(E.yU(k,"/deliveries/"+n+"/accept","Could not accept this delivery.",null),$async$EI)
case 7:p=f
if(r.c==null){w=1
break}r.n(new C.aLY(r,d))
k=r.c.U(x.q).f
m=p.ok
if(m==null)m="in My deliveries"
k.bO(A.d7(null,null,null,B.E,null,B.B,null,A.i("Delivery #"+n+" accepted. Your pickup code is "+m+" \u2014 give it to the restaurant when you collect.",null,null,null,null,B.b6,null,null,null,null),null,B.ae,null,null,null,null,null,null,null,null,null,null))
t=2
w=6
break
case 4:t=3
j=s.pop()
o=A.a5(j)
k=r.c
if(k==null){w=1
break}k.U(x.q).f.bO(A.d7(null,null,null,B.G,null,B.B,null,A.i(A.b8(o),null,null,null,null,B.b6,null,null,null,null),null,B.ae,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$EI,v)},
t(d){var w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.w
if(l!=null&&J.f(J.C(l,"can_work"),!1)){if(d.di(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b4:B.aW
return A.de(m,w,A.dZ(!0,new C.L4(l,new C.aMa(n),m),B.Y,!0),m,m,!1,m,m)}if(d.di(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b4:B.aW
v=A.af(d,!0,x.d).f
if(v==null)v=""
if(n.f)if(J.d9(n.d))u=m
else{u=J.b9(n.d)
t=J.b9(n.d)===1?"":"s"
t=""+u+" job"+t+" near you right now."
u=t}else u="You're offline. Go online to get delivery jobs."
u=A.HZ(v,G.vi,"rider",u)
if(n.f)v=B.E.N(0.12)
else v=A.c(d).ax.a===B.c?B.at:B.as
t=A.a_(20)
if(n.f)s=B.E.N(0.5)
else s=A.c(d).ax.a===B.c?B.F:B.H
s=A.b_(s,B.n,1)
if(n.f)r=B.E
else r=A.c(d).ax.a===B.c?B.R:B.Q
r=A.ed(m,m,m,B.X,new A.X(r,m,m,m,m,m,B.ax),B.cy,m,8,m,m,8)
q=n.f
p=q?"Online":"Offline"
if(q)q=B.E
else q=A.c(d).ax.a===B.c?B.R:B.Q
o=x.p
t=A.W(A.a([D.Te,B.az,A.cf(m,A.ed(m,A.W(A.a([r,B.bO,A.i(p,m,m,m,m,A.t(m,m,q,m,m,m,m,m,m,m,m,13,m,m,B.a2,m,m,!0,m,m,m,m,m,m,m,m),m,m,m,m)],o),B.i,m,B.e,B.f,0,m),m,B.X,new A.X(v,m,s,t,m,m,B.p),B.cy,m,m,m,F.lc,m),B.K,!1,D.apT,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,n.gaFZ(),m,m,m,m,m,m,!1,B.aa),B.ag,F.qs],o),B.i,m,B.bI,B.f,0,m)
s=n.gw1()
v=n.QR(F.jf,""+J.b9(n.d),"Available")
q=n.r
r=q==null?m:q.f
r=n.QR(F.jd,""+(r==null?0:r),"Completed today")
q=n.r
q=q==null?m:q.e
v=A.bv(A.dF(A.a([v,r,n.QR(B.jb,A.bH(q==null?0:q),"Earned today")],o),m,m,B.ld,m,B.aJ,!1),80,m)
if(!n.f)r=D.T5
else if(n.e)r=B.bX
else{r=n.x
if(r.length!==0)r=new A.d5(B.b7,"Connection failed",r,"Retry",s,m)
else r=J.d9(n.d)?D.T1:A.ev(A.rl(m,new C.aMb(n),J.b9(n.d),G.vk),B.m,s)}return A.de(m,w,A.dZ(!0,A.U(A.a([u,new A.Z(G.vl,t,m),B.a4,new C.L1(s,m),v,B.a5,A.ae(r,1)],o),B.q,m,B.e,B.f,0,B.k),B.Y,!0),m,m,!1,m,m)},
QR(d,e,f){var w,v,u,t,s,r=null,q=this.c
q.toString
q=A.bS(q)
w=A.a_(14)
v=this.c
v.toString
u=A.b_(A.c(v).ax.a===B.c?B.F:B.H,B.n,1)
t=A.ao(d,B.m,r,r,20)
s=this.c
s.toString
v=x.p
return A.a3(r,A.W(A.a([t,B.ag,A.U(A.a([A.i(e,r,r,r,r,A.t(r,r,A.c(s).ax.a===B.c?B.v:B.u,r,r,r,r,r,r,r,r,18,r,r,B.C,r,r,!0,r,r,r,r,r,r,r,r),r,r,r,r),A.i(f,r,r,r,r,D.mU,r,r,r,r)],v),B.q,r,B.aX,B.f,0,B.k)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(q,r,u,w,r,r,B.p),r,r,r,D.Re,D.ve,r,r,r)},
apv(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j=l.c
j.toString
j=A.bS(j)
w=A.a_(16)
v=A.b_(B.m.N(0.25),B.n,1)
u=""+d.a
t=x.p
s=A.W(A.a([A.i("Order #"+u,k,k,k,k,D.mW,k,k,k,k),A.i(A.bH(d.b),k,k,k,k,D.mW.bi(B.m),k,k,k,k)],t),B.i,k,B.bI,B.f,0,k)
r=A.a3(k,D.WL,B.j,k,k,new A.X(B.m.N(0.12),k,k,k,k,k,B.ax),k,32,k,k,k,k,k,32)
q=l.c
q.toString
p=A.i("Pickup",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.av,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
o=d.f
q=o==null?"Restaurant":o
o=l.c
o.toString
r=A.W(A.a([r,B.az,A.ae(A.U(A.a([p,A.i(q,k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,14,k,k,B.av,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t),B.i,k,B.e,B.f,0,k)
q=l.c
q.toString
p=A.a3(k,k,B.j,A.c(q).ax.a===B.c?B.F:B.H,k,k,k,20,k,k,k,k,k,2)
o=A.a3(k,D.Wz,B.j,k,k,new A.X(B.E.N(0.12),k,k,k,k,k,B.ax),k,32,k,k,k,k,k,32)
n=l.c
n.toString
q=A.i("Dropoff",k,k,k,k,A.t(k,k,A.c(n).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.av,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
if(d.gCF())n="Pinned location"
else{n=d.z
n.toString
n=B.d.a2(n)}m=l.c
m.toString
q=A.a([o,B.az,A.ae(A.U(A.a([q,A.i(n,k,2,B.a1,k,A.t(k,k,A.c(m).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,14,k,k,B.av,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gaaH())B.b.H(q,A.a([B.ab,new A.ur(D.w8,"Directions","Directions to the drop-off",new C.aLZ(l,d),new A.y("available-directions-"+u,x.O))],t))
u=A.a([new A.Z(B.bb,A.U(A.a([s,B.aA,r,new A.Z(D.RR,p,k),A.W(q,B.i,k,B.e,B.f,0,k)],t),B.q,k,B.e,B.f,0,B.k),k)],t)
if(d.cy.length!==0){s=l.c
s.toString
B.b.H(u,A.a([A.hN(A.c(s).ax.a===B.c?B.F:B.H,1,k),new A.Z(D.RW,new E.wr(d,!0,k),k)],t))}t=l.c
t.toString
u.push(A.hN(A.c(t).ax.a===B.c?B.F:B.H,1,k))
u.push(new A.Z(B.ba,A.bv(A.YL(D.VY,k,D.al_,new C.aM_(l,d)),44,1/0),k))
return A.a3(k,A.U(u,B.i,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(j,k,v,w,k,k,B.p),k,k,k,B.ft,k,k,k,k)}}
C.Qo.prototype={
L(){return new C.Qp(A.a([],x.A),null,!1)}}
C.Qp.prototype={
nS(d){return this.aAe(d)},
aAe(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$nS=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.l(s)+","+A.l(d.as):d.z
if(r==null||B.d.a2(r).length===0){t.c.U(x.q).f.bO(D.Id)
w=1
break}w=3
return A.j(A.ug(C.brW("https","www.google.com","/maps/dir/",A.Q(["api","1","destination",r],x.N,x.z)).git(),B.lR,null),$async$nS)
case 3:if(!f&&t.c!=null)t.c.U(x.q).f.bO(D.Ic)
case 1:return A.o(u,v)}})
return A.p($async$nS,v)},
Z(){var w=this
w.ab()
w.j0()
w.iU(new C.aZV(w))},
w2(d){return this.ay_(d)},
j0(){return this.w2(!1)},
ay_(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j
var $async$w2=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=q.c
k.toString
p=A.af(k,!1,x.d)
if(p.c==null){w=1
break}k=!d
if(k)q.n(new C.aZH(q))
t=4
m=p.c
m.toString
w=7
return A.j(A.mF(m),$async$w2)
case 7:o=f
if(q.c==null){r=[1]
w=5
break}q.n(new C.aZI(q,o))
r.push(6)
w=5
break
case 4:t=3
j=s.pop()
n=A.a5(j)
if(q.c==null||d){r=[1]
w=5
break}q.n(new C.aZJ(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null&&k)q.n(new C.aZK(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$w2,v)},
AE(d){return this.aCg(d)},
aCg(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$AE=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
w=3
return A.j(A.f6(null,null,!0,null,new C.aZS(d),n,null,!0,x.y),$async$AE)
case 3:if(f!==!0||r.c==null){w=1
break}t=5
n=r.c
n.toString
n=A.af(n,!1,x.d).c
n.toString
p=""+d.a
w=8
return A.j(E.yU(n,"/deliveries/"+p+"/release","Could not release this delivery.",null),$async$AE)
case 8:if(r.c==null){w=1
break}r.n(new C.aZT(r,d))
n=r.c.U(x.q).f
n.JI()
n.bO(A.d7(null,null,null,null,null,B.B,null,A.i("Order #"+p+" released to other riders.",null,null,null,null,null,null,null,null,null),null,B.ae,null,null,null,null,null,null,null,null,null,null))
t=2
w=7
break
case 5:t=4
m=s.pop()
q=A.a5(m)
n=r.c
if(n==null){w=1
break}n=n.U(x.q).f
n.JI()
n.bO(A.d7(null,null,null,B.G,null,B.B,null,A.i(A.b8(q),null,null,null,null,B.b6,null,null,null,null),null,B.ae,null,null,null,null,null,null,null,null,null,null))
w=7
break
case 4:w=2
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$AE,v)},
F2(d){return this.aoq(d)},
aoq(d){var w=0,v=A.q(x.H),u=this,t,s
var $async$F2=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=u.c
s.toString
s=A.af(s,!1,x.d).c
s.toString
t=u.c
t.toString
w=2
return A.j(E.ai8(t,"Complete delivery",null,"Ask the customer for the 4-digit delivery code shown in their FindFood app. Hand over the food once the code is accepted.",new C.aZG(u,s,d),"Enter the customer's code"),$async$F2)
case 2:if(f&&u.c!=null)u.c.U(x.q).f.bO(D.act)
return A.o(null,v)}})
return A.p($async$F2,v)},
t(d){var w,v=this,u=null
if(v.e)w=B.bX
else{w=v.f
if(w.length!==0)w=new A.d5(B.b7,"Failed to load",w,"Retry",v.gw1(),u)
else w=J.d9(v.d)?D.T6:A.ev(A.rl(u,new C.aZU(v),J.b9(v.d),G.vh),B.m,v.gw1())}return A.de(u,u,A.dZ(!0,A.U(A.a([D.a5Z,A.ae(w,1)],x.p),B.q,u,B.e,B.f,0,B.k),B.Y,!0),u,u,!1,u,u)},
ayP(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="the restaurant",i=d.c,h=i==="out_for_delivery",g=l.c
g.toString
g=A.bS(g)
w=A.a_(16)
if(h)v=B.m.N(0.4)
else{v=l.c
v.toString
v=A.c(v).ax.a===B.c?B.F:B.H}v=A.b_(v,B.n,1)
u=""+d.a
t=x.p
s=A.a([A.ae(A.i("Order #"+u,k,k,k,k,D.mW,k,k,k,k),1)],t)
if(i!=="cancelled"){r=d.f
if(r==null)r=j
B.b.H(s,A.a([E.bmg(new A.y("rider-chat-"+u,x.O),new C.aZL(l,d),"the customer or "+r),B.ab],t))}s.push(new A.Ce(i,k))
s=A.a([A.W(s,B.i,k,B.e,B.f,0,k),B.aI,A.i(A.bH(d.b),k,k,k,k,D.k5.bi(B.m),k,k,k,k)],t)
r=d.z
if(r!=null||d.Q!=null){if(d.gCF())r="Pinned location"
else{r.toString
r=B.d.a2(r)}r=A.a([A.i(r,k,2,B.a1,k,D.k5,k,k,k,k)],t)
if(d.gCF()){q=l.c
q.toString
r.push(A.i("Shared from the customer's phone",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,12,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}r=A.a([D.Wp,B.ab,A.ae(A.U(r,B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gaaH())B.b.H(r,A.a([B.ab,new A.ur(D.w8,"Directions","Directions to the drop-off",new C.aZM(l,d),new A.y("rider-directions-"+u,x.O))],t))
B.b.H(s,A.a([B.O,A.W(r,B.i,k,B.e,B.f,0,k)],t))}if(d.ch!=null)r=i==="pending"||i==="preparing"||i==="ready"
else r=!1
if(r&&d.ok!=null){r=x.O
q=d.ok
q.toString
p=d.f
if(p==null)p=j
i=i==="ready"?"The food is ready.":"The kitchen is still preparing it."
o=l.c
o.toString
n=A.i("In the bag",k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,13,k,k,B.a2,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
m=l.c
m.toString
o=A.c(m).ax.a===B.c?B.v:B.u
m=l.c
m.toString
m=A.c(m).ax.a===B.c?B.F:B.H
B.b.H(s,A.a([B.aA,new A.I0("Pickup code",q,"Check the bag is labelled #"+u+" and has everything below, then give this code to "+p+". "+i,B.da,new A.y("rider-pickup-code-"+u,r)),B.O,n,B.aI,new E.wr(d,!1,k),B.a4,A.bv(A.wq(D.Xa,new A.y("rider-release-"+u,r),D.aiS,new C.aZN(l,d),A.JE(k,k,k,k,k,k,k,k,k,o,k,k,k,k,new A.bG(A.a_(12),B.L),new A.ay(m,1,B.n,-1),k,k,B.IM,k)),46,1/0)],t))}if(h)B.b.H(s,A.a([B.aA,A.bv(A.YL(D.WV,new A.y("rider-complete-"+u,x.O),D.aj9,new C.aZO(l,d)),46,1/0)],t))
return A.a3(k,A.U(s,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(g,k,v,w,k,k,B.p),k,k,k,B.ft,B.bb,k,k,k)}}
C.Sm.prototype={
L(){return new C.Sn()}}
C.Sn.prototype={
Z(){this.ab()
this.j0()},
j0(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j0=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d).c
if(p==null){w=1
break}q.n(new C.b7M(q))
t=4
w=7
return A.j(C.Wm(p),$async$j0)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.n(new C.b7N(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a5(k)
if(q.c==null){r=[1]
w=5
break}q.n(new C.b7O(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.n(new C.b7P(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j0,v)},
t(d){var w,v,u,t,s,r,q=this,p=null,o=q.d,n=q.gw1(),m=x.p,l=A.a([D.ajZ,B.b0,D.a9c],m)
if(q.f&&o==null)l.push(D.a62)
else{w=q.e
if(w!=null&&o==null)l.push(A.U(A.a([A.i(w,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.t:B.r,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),A.c3(B.e3,p,p,p,n,p,p)],m),B.i,p,B.e,B.f,0,B.k))
else if(o!=null){w=A.a_(16)
v=A.b_(B.m.N(0.3),B.n,1)
u=A.bH(o.e)
u=A.i(u,D.ard,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.m:B.ar,p,p,p,p,p,p,p,p,36,p,p,B.C,p,p,!0,p,-1,p,p,p,p,p,p),p,p,p,p)
t=A.ao(D.Um,A.c(d).ax.a===B.c?B.t:B.r,p,p,14)
s=o.f
r=s===1?"y":"ies"
w=A.a3(p,A.U(A.a([D.aiL,B.aI,u,B.ak,A.W(A.a([t,B.bO,A.i(""+s+" deliver"+r+" completed today",p,p,p,p,D.mU.bi(A.c(d).ax.a===B.c?B.t:B.r),p,p,p,p)],m),B.i,p,B.e,B.f,0,p)],m),B.q,p,B.e,B.f,0,B.k),B.j,p,p,new A.X(B.hx,p,v,w,p,p,B.p),p,p,p,p,B.d5,p,p,1/0)
v=A.W(A.a([q.H2("This week",A.bH(o.r)),B.e1,q.H2("This month",A.bH(o.w))],m),B.i,p,B.e,B.f,0,p)
u=q.H2("All time",A.bH(o.c))
t=o.x
m=A.a([w,B.aA,v,B.aA,A.W(A.a([u,B.e1,q.H2("Rating",t==null?"No ratings yet":"\u2605 "+B.h.ai(t,1))],m),B.i,p,B.e,B.f,0,p),B.aG,D.ak2,B.aA],m)
w=o.y
if(w.length===0)m.push(A.i("Completed deliveries will appear here.",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.R:B.Q,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p))
else B.b.H(m,new A.aA(w,q.gaBY(),A.ap(w).i("aA<1,d>")))
B.b.H(l,m)}}return A.de(p,p,A.dZ(!0,A.ev(A.dF(l,p,p,B.au,p,B.V,!1),B.m,n),B.Y,!0),p,p,!1,p,p)},
H2(d,e){var w,v,u,t=null,s=this.c
s.toString
s=A.bS(s)
w=A.a_(14)
v=this.c
v.toString
u=A.b_(A.c(v).ax.a===B.c?B.F:B.H,B.n,1)
return A.ae(A.a3(t,A.U(A.a([A.i(d,t,t,t,t,D.mU,t,t,t,t),B.aH,A.i(e,t,t,t,t,D.mW,t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k),B.j,t,t,new A.X(s,t,u,w,t,t,B.p),t,t,t,t,B.bb,t,t,t),1)},
aBZ(d){var w,v,u,t,s,r=null,q=d.e,p=A.a([],x.s),o=d.b
if(o!=null)p.push(o)
if(q!=null)p.push(""+A.ce(q)+"/"+A.bD(q)+" "+B.d.da(B.l.k(A.kl(q)),2,"0")+":"+B.d.da(B.l.k(A.l6(q)),2,"0"))
w=B.b.bj(p," \xb7 ")
p=this.c
p.toString
p=A.bS(p)
o=A.a_(12)
v=this.c
v.toString
u=A.b_(A.c(v).ax.a===B.c?B.F:B.H,B.n,1)
t=A.i("Order #"+d.a,r,r,r,r,D.k5,r,r,r,r)
s=this.c
s.toString
v=x.p
return A.a3(r,A.W(A.a([A.ae(A.U(A.a([t,A.i(w,r,r,r,r,D.mU.bi(A.c(s).ax.a===B.c?B.R:B.Q),r,r,r,r)],v),B.q,r,B.e,B.f,0,B.k),1),A.i(A.bH(d.d),r,r,r,r,D.k5.SI(B.m,B.z),r,r,r,r)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(p,r,u,o,r,r,B.p),r,r,r,B.bU,D.ve,r,r,r)}}
C.ad0.prototype={
t(d){var w=null,v=x.p
return A.de(w,w,A.dZ(!0,A.dF(A.a([D.akv,B.aG,D.Km,B.dA,new A.up("rider",A.a([new A.j1(K.py,"Payout account","Where your delivery pay is sent",new C.b8n(d),w,D.arb)],v),w),B.aG,K.r_],v),w,w,B.au,w,B.V,!1),B.Y,!0),w,w,!1,w,w)}}
C.agD.prototype={
j(){var w=this.dJ$
if(w!=null)w.av(0)
this.a6()}}
C.L1.prototype={
L(){return new C.So(B.eR,null,!1)}}
C.So.prototype={
Z(){var w=this
w.ab()
w.jt()
w.iU(w.gEQ())},
bb(){var w,v,u=this
u.cs()
w=u.c
w.toString
w=A.af(w,!0,x.Q)
v=w==null?null:w.r
if(v==null)v=0
w=u.f
if(w!==-1&&v!==w)u.jt()
u.f=v},
jt(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$jt=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
q=A.af(n,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.j(C.ajQ(q),$async$jt)
case 7:p=e
if(r.c!=null)r.n(new C.b7S(r,p))
t=2
w=6
break
case 4:t=3
m=s.pop()
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$jt,v)},
v6(d,e){return this.ama(d,e)},
ama(d,e){var w=0,v=A.q(x.H),u=1,t=[],s=[],r=this,q,p,o,n,m,l,k
var $async$v6=A.m(function(f,g){if(f===1){t.push(g)
w=u}for(;;)switch(w){case 0:m=J.a8(d)
l=A.bY(m.h(d,"id"))
r.n(new C.b7Q(r,l))
o=r.c
o.toString
o=A.af(o,!1,x.d).c
o.toString
q=o
u=3
w=e?6:8
break
case 6:w=9
return A.j(C.ajg(q,l),$async$v6)
case 9:o=r.c
if(o!=null)A.b5(o,"Order #"+A.l(m.h(d,"order_id"))+" is yours. Find it in My Deliveries for your pickup code.",!1)
r.a.c.$0()
w=7
break
case 8:w=10
return A.j(C.ajv(q,l),$async$v6)
case 10:case 7:s.push(5)
w=4
break
case 3:u=2
k=t.pop()
p=A.a5(k)
m=r.c
if(m!=null)A.b5(m,A.b8(p),!0)
s.push(5)
w=4
break
case 2:s=[1]
case 4:u=1
if(r.c!=null)r.n(new C.b7R(r))
w=11
return A.j(r.jt(),$async$v6)
case 11:w=s.pop()
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$v6,v)},
t(d){var w,v,u,t,s,r,q=this,p=null
if(J.d9(q.d))return B.aO
w=A.a([A.i("Requests for you",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.v:B.u,p,p,p,p,p,p,p,p,17,p,p,B.C,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),B.a5],x.p)
for(v=J.bs(q.d),u=q.gEQ();v.B();){t=v.gO(v)
s=q.e
r=J.C(t,"id")
w.push(new C.aai(t,s==null?r==null:s===r,new C.b7T(q,t),u,p))}return new A.Z(D.Se,A.U(w,B.q,D.aof,B.e,B.f,0,B.k),p)}}
C.aai.prototype={
t(a1){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="total_amount",i="restaurant_address",h=A.c(a1).ax.a===B.c?B.v:B.u,g=A.c(a1).ax.a===B.c?B.t:B.r,f=Date.now(),e=l.c,d=J.a8(e),a0=A.cz(d.h(e,"seconds_left"))
a0=a0==null?k:B.h.bm(a0)
w=new A.co(f,0,!1).pg(A.eG(0,0,a0==null?0:a0).a)
f=x.g.a(d.h(e,"items"))
if(f==null)f=B.bm
v=J.ei(f,new C.b_r(),x.N).bj(0,", ")
f=A.l(d.h(e,"id"))
a0=x.O
u=A.bS(a1)
t=A.a_(18)
s=A.b_(B.m,B.n,1.5)
r=A.a([new A.dj(0,B.bR,B.m.N(0.18),B.CX,16)],x.V)
q=d.h(e,"restaurant_name")
p=x.p
q=A.a([D.X8,B.ab,A.ae(A.i(A.l(q==null?"A restaurant":q)+" asked you",k,k,k,k,A.t(k,k,h,k,k,k,k,k,k,k,k,15,k,k,B.C,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k),1)],p)
if(A.fT(d.h(e,j))){o=A.bH(A.bY(d.h(e,j)))
q.push(A.i(o,k,k,k,k,A.t(k,k,A.c(a1).ax.a===B.c?B.m:B.ar,k,k,k,k,k,k,k,k,k,k,k,B.C,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}q=A.W(q,B.i,k,B.e,B.f,0,k)
o=A.l(d.h(e,"order_id"))
n=v.length===0?"":" \xb7 "+v
n=A.a([q,B.aI,A.i("Order #"+o+n,k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],p)
if(d.h(e,i)!=null)n.push(A.i("Pick up: "+A.l(d.h(e,i)),k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))
n.push(B.O)
n.push(new E.zy(w,new C.b_s(l,g),k))
n.push(B.O)
q=A.l(d.h(e,"id"))
o=l.d
m=o?k:new C.b_t(l)
m=A.ae(A.wp(D.ajR,new A.y("rider-offer-decline-"+q,a0),m,k),1)
e=A.l(d.h(e,"id"))
d=o?k:new C.b_u(l)
n.push(A.W(A.a([m,B.ag,A.ae(new A.cO("Accept delivery",d,o,k,new A.y("rider-offer-accept-"+e,a0)),2)],p),B.i,k,B.e,B.f,0,k))
return A.a3(k,A.U(n,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(u,k,s,t,r,k,B.p),k,k,new A.y("rider-offer-card-"+f,a0),B.bU,B.bb,k,k,k)}}
C.aha.prototype={
j(){var w=this.dJ$
if(w!=null)w.av(0)
this.a6()}}
C.L3.prototype={
L(){return new C.Sp()}}
C.Sp.prototype={
Z(){this.ab()
this.fZ()},
fZ(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$fZ=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
q=A.af(n,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.j(E.Wh(q),$async$fZ)
case 7:p=e
if(r.c!=null)r.n(new C.b7X(r,p))
t=2
w=6
break
case 4:t=3
m=s.pop()
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$fZ,v)},
za(){var w=0,v=A.q(x.H),u=this,t
var $async$za=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:t=u.c
t.toString
w=4
return A.j(A.e4(t,new E.q4(!0,null),x.P),$async$za)
case 4:w=e!=null?2:3
break
case 2:w=5
return A.j(u.fZ(),$async$za)
case 5:case 3:return A.o(null,v)}})
return A.p($async$za,v)},
t(a5){var w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,a0="status",a1="paid",a2="failed",a3="order_count",a4=this.d
if(a4==null)return B.aO
w=A.c(a5).ax.a===B.c?B.v:B.u
v=A.c(a5).ax.a===B.c?B.t:B.r
u=J.a8(a4)
t=J.f(u.h(a4,"payout_mode"),"automatic")
s=E.ai7(a4)
r=x.g.a(u.h(a4,"payouts"))
if(r==null)r=B.bm
q=J.eZ(r,x.P)
r=A.bS(a5)
p=A.a_(18)
o=A.b_(A.c(a5).ax.a===B.c?B.F:B.H,B.n,1)
n=A.i("Waiting to be paid",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
m=A.cz(u.h(a4,"owed"))
m=m==null?d:B.h.bm(m)
l=x.p
m=A.ae(A.U(A.a([n,A.i(A.bH(m==null?0:m),D.anL,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,22,d,d,B.ds,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)
n=A.i("Paid to you",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
k=A.cz(u.h(a4,"paid_total"))
k=k==null?d:B.h.bm(k)
n=A.W(A.a([m,A.ae(A.U(A.a([n,A.i(A.bH(k==null?0:k),d,d,d,d,D.ag9,d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)],l),B.i,d,B.e,B.f,0,d)
u=A.cz(u.h(a4,"rider_share_percent"))
u=H.hH(u==null?100:u)
m=t?"after each delivery":"weekly"
m=A.a([n,B.ak,A.i("You earn "+u+" of each delivery fee, paid "+m+".",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,1.4,!0,d,d,d,d,d,d,d,d),d,d,d,d),B.O],l)
u=this.galK()
if(s==null)m.push(A.bv(I.Z1(G.wS,D.an_,D.akY,u),d,1/0))
else{n=A.a_(10)
k=A.ae(A.i("Paid to "+s,d,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,13.5,d,d,B.a2,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d),1)
m.push(A.dm(!1,n,!0,A.W(A.a([D.WZ,B.ab,k,A.i("Change",d,d,d,d,A.t(d,d,A.c(a5).ax.a===B.c?B.m:B.ar,d,d,d,d,d,d,d,d,13,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d,!0,d,d,d,d,d,d,d,d,d,d,d,u,d,d,d,d,d,d,d))}if(!q.gaf(q)){u=A.a([A.hN(A.c(a5).ax.a===B.c?B.F:B.H,24,d)],l)
for(n=A.h4(q,0,A.kA(3,"count",x.S),q.$ti.i("al.E")),k=n.$ti,n=new A.bf(n,n.gC(0),k.i("bf<aO.E>")),k=k.i("aO.E");n.B();){j=n.d
if(j==null)j=k.a(j)
i=J.a8(j)
if(J.f(i.h(j,a0),a1))h=B.cA
else h=J.f(i.h(j,a0),a2)?B.lC:B.hO
if(J.f(i.h(j,a0),a1))g=B.E
else g=J.f(i.h(j,a0),a2)?B.G:B.ad
g=A.ao(h,g,d,d,16)
h=A.bH(B.h.bm(A.c1(i.h(j,"amount"))))
f=A.l(i.h(j,a3))
e=J.f(i.h(j,a3),1)?"y":"ies"
h=A.i(h+" \xb7 "+f+" deliver"+e,d,d,d,d,new A.x(!0,w,d,d,d,d,13,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)
if(J.f(i.h(j,a0),a1))j=H.bjV(i.h(j,"paid_at"))
else j=J.f(i.h(j,a0),a2)?"Failed":"Sending\u2026"
u.push(new A.Z(F.oB,A.W(A.a([g,B.ab,new A.ds(1,B.b5,h,d),A.i(j,d,d,d,d,new A.x(!0,v,d,d,d,d,12,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d))}B.b.H(m,u)}return A.a3(d,A.U(m,B.q,d,B.e,B.f,0,B.k),B.j,d,d,new A.X(r,d,o,p,d,d,B.p),d,d,D.apz,B.v4,B.dM,d,d,1/0)}}
C.L4.prototype={
L(){var w=$.aa()
return new C.Sv(new A.bq(B.a3,w),new A.bq(B.a3,w),new A.bq(B.a3,w),new A.bq(B.a3,w),new A.bq(B.a3,w))},
h8(d){return this.d.$1(d)}}
C.Sv.prototype={
Z(){var w,v,u,t=this
t.ab()
w=t.a.c
v=J.a8(w)
u=v.h(w,"ghana_card")
t.d.sc_(0,A.l(u==null?"":u))
u=v.h(w,"licence_number")
t.e.sc_(0,A.l(u==null?"":u))
u=v.h(w,"plate")
t.f.sc_(0,A.l(u==null?"":u))
u=v.h(w,"emergency_name")
t.r.sc_(0,A.l(u==null?"":u))
u=v.h(w,"emergency_phone")
t.w.sc_(0,A.l(u==null?"":u))
v=v.h(w,"vehicle")
t.x=A.l(v==null?"motorbike":v)},
j(){var w,v,u,t=this
for(w=[t.d,t.e,t.f,t.r,t.w],v=0;v<5;++v){u=w[v]
u.R8$=$.aa()
u.p4$=0}t.a6()},
AA(){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p,o
var $async$AA=A.m(function(d,e){if(d===1){t.push(e)
w=u}for(;;)switch(w){case 0:u=3
q=s.c
q.toString
q=A.af(q,!1,x.d).c
q.toString
w=6
return A.j(C.Wn(q),$async$AA)
case 6:r=e
s.a.h8(r)
u=1
w=5
break
case 3:u=2
o=t.pop()
w=5
break
case 2:w=1
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$AA,v)},
H3(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g,f
var $async$H3=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.x
g=h==="motorbike"||h==="car"
h=A.cE("^GHA-?\\d{9}-?\\d$",!1,!1)
n=q.d
m=B.d.a2(n.a.a)
if(!h.b.test(m)){h=q.c
h.toString
A.b5(h,"Enter your Ghana Card number, e.g. GHA-123456789-0.",!0)
w=1
break}if(g)h=B.d.a2(q.e.a.a).length<4||B.d.a2(q.f.a.a).length<4
else h=!1
if(h){h=q.c
h.toString
A.b5(h,"Add your licence number and number plate.",!0)
w=1
break}h=q.r
if(B.d.a2(h.a.a).length<2||B.d.a2(q.w.a.a).length<9){h=q.c
h.toString
A.b5(h,"Add someone we can call in an emergency.",!0)
w=1
break}q.n(new C.b8o(q))
t=4
m=q.c
m.toString
m=A.af(m,!1,x.d).c
m.toString
n=B.d.a2(n.a.a)
l=q.x
k=g?B.d.a2(q.e.a.a):null
j=g?B.d.a2(q.f.a.a):null
w=7
return A.j(C.akZ(m,A.Q(["ghana_card",n,"vehicle",l,"licence_number",k,"plate",j,"emergency_name",B.d.a2(h.a.a),"emergency_phone",B.d.a2(q.w.a.a)],x.N,x.z)),$async$H3)
case 7:p=e
q.a.h8(p)
h=q.c
if(h!=null)A.b5(h,"Sent! We'll let you know once you're approved.",!1)
r.push(6)
w=5
break
case 4:t=3
f=s.pop()
o=A.a5(f)
h=q.c
if(h!=null)A.b5(h,A.b8(o),!0)
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.n(new C.b8p(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$H3,v)},
t(d){var w,v,u,t,s,r,q,p,o,n,m,l,k,j=this,i=null,h=j.a.c,g=J.a8(h),f=A.l(g.h(h,"status")),e=x.g.a(g.h(h,"missing"))
if(e==null)e=B.bm
w=J.ei(e,new C.b8r(),x.N).i9(0)
v=A.af(d,!0,x.d)
u=A.c(d).ax.a===B.c?B.v:B.u
t=A.c(d).ax.a===B.c?B.t:B.r
s=new C.b8u(d,t,u)
e=v.f
if(e==null)e=""
r=f==="pending"
e=A.HZ(e,F.vj,"rider",r?"We're checking your details.":"Let's get you verified so you can start earning.")
q=x.p
p=A.a([],q)
if(r)p.push(new C.D1(B.fn,B.lD,"Thanks! Your details are with FindFood","We may call you to meet and see your Ghana Card"+(J.f(g.h(h,"vehicle"),"motorbike")||J.f(g.h(h,"vehicle"),"car")?" and licence":"")+". You'll get a notification as soon as you're approved.",D.aqC))
else{r=A.a([],q)
o=f==="rejected"
if(o){g=g.h(h,"rejection_reason")
r.push(new C.D1(B.G,D.V4,"We couldn't approve you yet",A.l(g==null?"Please check your details.":g)+". Fix it below and send again.",D.aqH))}else r.push(D.arN)
r.push(B.a4)
r.push(s.$4(1,"A clear photo of your face",!w.m(0,"photo"),D.SW))
r.push(s.$4(2,"Your phone number",!w.m(0,"phone"),A.c3(D.al3,D.anV,i,i,new C.b8s(j,d),i,i)))
r.push(s.$4(3,"Your ID and vehicle",!1,i))
r.push(B.aI)
r.push(A.cM(j.d,"Ghana Card number (GHA-123456789-0)",D.aoj,i,1,!1,i,D.U8,i,i,i))
r.push(B.O)
r.push(A.i("How do you deliver?",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a5)
g=A.a([],q)
for(n=D.Cy.gh3(D.Cy),n=n.gal(n),m=x.O;n.B();){l=n.gO(n)
k=l.a
g.push(A.qy(i,i,new A.y("vehicle-"+k,m),A.i(l.b,i,i,i,i,i,i,i,i,i),i,new C.b8t(j,l),j.x===k,i,i,i,i))}r.push(A.fQ(B.br,g,B.bM,8,8))
g=j.x
if(g==="motorbike"||g==="car")B.b.H(r,A.a([B.O,A.cM(j.e,"Driver's licence number",D.an5,i,1,!1,i,B.wn,i,i,i),B.ak,A.cM(j.f,"Number plate, e.g. GR 1234-24",D.aob,i,1,!1,i,B.lx,i,i,i)],q))
r.push(B.a4)
r.push(A.i("Emergency contact",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a5)
r.push(A.cM(j.r,"Their name",D.aoH,i,1,!1,i,B.dR,i,i,i))
r.push(B.ak)
r.push(A.cM(j.w,"Their phone number",D.aqk,B.ie,1,!1,i,B.lw,i,i,i))
r.push(B.a5)
r.push(A.i("Only FindFood admins see these details. We never share your Ghana Card number.",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,12,i,i,i,i,1.4,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a4)
g=o?"Send again":"Send for approval"
o=j.y
r.push(new A.cO(g,o||w.a!==0?i:j.gaCS(),o,i,D.ap9))
if(w.a!==0)r.push(new A.Z(B.j2,A.i("Add your photo and phone number first (steps 1 and 2).",i,i,i,i,A.t(i,i,A.c(d).ax.a===B.c?B.m:B.ar,i,i,i,i,i,i,i,i,12.5,i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i),i))
B.b.H(p,r)}return A.ev(A.dF(A.a([e,new A.Z(B.ld,A.U(p,B.q,i,B.e,B.f,0,B.k),i)],q),i,i,D.Rc,i,B.V,!1),B.m,j.gaC7())}}
C.D1.prototype={
t(d){var w,v,u=this,t=null,s=u.c,r=s.N(0.1),q=A.a_(14),p=A.b_(s.N(0.35),B.n,1)
s=A.ao(u.d,s,t,t,22)
w=A.i(u.e,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.v:B.u,t,t,t,t,t,t,t,t,t,t,t,B.C,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)
v=x.p
return A.a3(t,A.W(A.a([s,B.ag,A.ae(A.U(A.a([w,B.h0,A.i(u.f,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.t:B.r,t,t,t,t,t,t,t,t,13,t,t,t,t,1.4,!0,t,t,t,t,t,t,t,t),t,t,t,t)],v),B.q,t,B.e,B.f,0,B.k),1)],v),B.q,t,B.e,B.f,0,t),B.j,t,t,new A.X(r,t,p,q,t,t,B.p),t,t,t,t,B.bl,t,t,1/0)}}
var z=a.updateTypes(["az<~>()","t4(@)","az<~>({silent:M})","d(t4)"])
C.aCp.prototype={
$1(d){var w,v,u,t,s="completed_at"
x.P.a(d)
w=J.a8(d)
v=w.h(d,"order_id")
u=w.h(d,"restaurant_name")
w.h(d,"delivery_address")
t=w.h(d,"earning")
if(t==null)t=0
if(w.h(d,s)==null)w=null
else{w=A.iH(J.bJ(w.h(d,s)))
w=w==null?null:w.hx()}return new C.t4(v,u,t,w)},
$S:z+1}
C.b7E.prototype={
$1(d){var w=this.a
return w.n(new C.b7D(w,d))},
$S:11}
C.b7D.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.aM1.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aM7.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.aM8.prototype={
$0(){return this.a.f=!this.b},
$S:0}
C.aM0.prototype={
$0(){return this.a.r=C.bpD(this.b)},
$S:0}
C.aMc.prototype={
$1(d){return this.a.GF()},
$S:42}
C.aMd.prototype={
$1(d){},
$S:19}
C.aM2.prototype={
$0(){var w=this.a
w.e=!0
w.x=""},
$S:0}
C.aM3.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.b9(v)},
$S:0}
C.aM4.prototype={
$0(){return this.a.x=A.b8(this.b)},
$S:0}
C.aM5.prototype={
$0(){return this.a.e=!1},
$S:0}
C.aM6.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.b9(v)},
$S:0}
C.aLY.prototype={
$0(){return J.yI(this.a.d,new C.aLX(this.b))},
$S:0}
C.aLX.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aMa.prototype={
$1(d){var w=this.a
return w.n(new C.aM9(w,d))},
$S:105}
C.aM9.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aMb.prototype={
$2(d,e){var w=this.a
return w.apv(J.C(w.d,e))},
$S:89}
C.aLZ.prototype={
$0(){return this.a.nS(this.b)},
$S:0}
C.aM_.prototype={
$0(){return this.a.EI(this.b)},
$S:0}
C.aZV.prototype={
$0(){return this.a.w2(!0)},
$S:2}
C.aZH.prototype={
$0(){var w=this.a
w.e=!0
w.f=""},
$S:0}
C.aZI.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.aZJ.prototype={
$0(){return this.a.f=A.b8(this.b)},
$S:0}
C.aZK.prototype={
$0(){return this.a.e=!1},
$S:0}
C.aZS.prototype={
$1(d){var w=null,v=A.i("Release order #"+this.a.a+"?",w,w,w,w,w,w,w,w,w)
return A.fF(A.a([A.c3(D.akJ,w,w,w,new C.aZQ(d),w,w),A.c3(D.akP,D.apq,w,w,new C.aZR(d),w,w)],x.p),w,D.aiY,!1,w,v)},
$S:18}
C.aZQ.prototype={
$0(){A.aZ(this.a,!1).aX(!1)
return null},
$S:0}
C.aZR.prototype={
$0(){A.aZ(this.a,!1).aX(!0)
return null},
$S:0}
C.aZT.prototype={
$0(){return J.yI(this.a.d,new C.aZP(this.b))},
$S:0}
C.aZP.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aZG.prototype={
$1(d){return this.adV(d)},
adV(d){var w=0,v=A.q(x.H),u,t=this,s,r,q
var $async$$1=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=t.c
w=3
return A.j(E.yU(t.b,"/orders/"+s.a+"/deliver","Could not complete this delivery.",d),$async$$1)
case 3:r=f
q=t.a
if(q.c==null){w=1
break}q.n(new C.aZF(q,s,r))
case 1:return A.o(u,v)}})
return A.p($async$$1,v)},
$S:58}
C.aZF.prototype={
$0(){var w=this.a,v=J.VQ(w.d,new C.aZE(this.b))
if(v!==-1)J.eL(w.d,v,this.c)},
$S:0}
C.aZE.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aZU.prototype={
$2(d,e){var w=this.a
return w.ayP(J.C(w.d,e))},
$S:89}
C.aZL.prototype={
$0(){var w,v,u=this.a.c
u.toString
w=this.b
v=w.f
return A.F1(u,w.a,A.a([D.ND,new A.kM("restaurant",v==null?"Restaurant":v,"Collecting the order")],x.J))},
$S:0}
C.aZM.prototype={
$0(){return this.a.nS(this.b)},
$S:0}
C.aZN.prototype={
$0(){return this.a.AE(this.b)},
$S:0}
C.aZO.prototype={
$0(){return this.a.F2(this.b)},
$S:0}
C.b7M.prototype={
$0(){var w=this.a
w.f=!0
w.e=null},
$S:0}
C.b7N.prototype={
$0(){return this.a.d=C.bpD(this.b)},
$S:0}
C.b7O.prototype={
$0(){return this.a.e=A.b8(this.b)},
$S:0}
C.b7P.prototype={
$0(){return this.a.f=!1},
$S:0}
C.b8n.prototype={
$0(){return A.e4(this.a,new E.q4(!0,null),x.P)},
$S:0}
C.ajN.prototype={
$1(d){return A.B0(d)},
$S:206}
C.b7S.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.b7Q.prototype={
$0(){return this.a.e=this.b},
$S:0}
C.b7R.prototype={
$0(){return this.a.e=null},
$S:0}
C.b7T.prototype={
$1(d){return this.a.v6(this.b,d)},
$S:6}
C.b_r.prototype={
$1(d){var w=J.a8(d)
return A.l(w.h(d,"quantity"))+"\xd7 "+A.l(w.h(d,"name"))},
$S:90}
C.b_s.prototype={
$2(d,e){var w,v,u,t=null,s=e.a
if(s===0)$.aj.aP$.push(new C.b_q(this.a))
w=A.a_(4)
s=B.l.c5(s,1e6)
v=s>30?B.m:B.G
u=A.c(d).ax.a===B.c?B.F:B.H
return A.U(A.a([A.fY(w,E.bon(u,v,5,s/180,t)),B.aH,A.i(E.bto(e)+" left to answer",t,t,t,t,A.t(t,t,this.b,t,t,t,t,t,t,t,t,12,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k)},
$S:744}
C.b_q.prototype={
$1(d){return this.a.f.$0()},
$S:5}
C.b_t.prototype={
$0(){return this.a.e.$1(!1)},
$S:0}
C.b_u.prototype={
$0(){return this.a.e.$1(!0)},
$S:0}
C.b7X.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.b8o.prototype={
$0(){return this.a.y=!0},
$S:0}
C.b8p.prototype={
$0(){return this.a.y=!1},
$S:0}
C.b8r.prototype={
$1(d){return A.l(d)},
$S:90}
C.b8u.prototype={
$4(d,e,f,g){var w,v,u,t=this,s=null
if(f)w=B.E
else w=A.c(t.a).ax.a===B.c?B.at:B.as
if(f)v=B.E
else v=A.c(t.a).ax.a===B.c?B.F:B.H
v=A.b_(v,B.n,1)
u=f?D.Ww:A.i(""+d,s,s,s,s,A.t(s,s,t.b,s,s,s,s,s,s,s,s,s,s,s,B.C,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s)
v=A.a3(B.a7,u,B.j,s,s,new A.X(w,s,v,s,s,s,B.ax),s,28,s,s,s,s,s,28)
w=f?B.Iz:s
w=A.a([v,B.az,A.ae(A.i(e,s,s,s,s,A.t(s,s,t.c,s,w,s,s,s,s,s,s,s,s,s,B.z,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s),1)],x.p)
if(!f&&g!=null)w.push(g)
return new A.Z(B.bU,A.W(w,B.i,s,B.e,B.f,0,s),s)},
$S:745}
C.b8s.prototype={
$0(){var w=0,v=A.q(x.H),u=this
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:w=2
return A.j(A.e4(u.b,B.rV,x.H),$async$$0)
case 2:w=3
return A.j(u.a.AA(),$async$$0)
case 3:return A.o(null,v)}})
return A.p($async$$0,v)},
$S:2}
C.b8t.prototype={
$1(d){var w=this.a
return w.n(new C.b8q(w,this.b))},
$S:6}
C.b8q.prototype={
$0(){return this.a.x=this.b.a},
$S:0};(function installTearOffs(){var w=a._instance_0u,v=a.installInstanceTearOff,u=a._instance_1u
var t
w(t=C.NC.prototype,"gaFZ","Hz",0)
w(t,"gw1","j0",0)
v(C.Qp.prototype,"gw1",0,0,null,["$1$silent","$0"],["w2","j0"],2,0,0)
w(t=C.Sn.prototype,"gw1","j0",0)
u(t,"gaBY","aBZ",3)
w(C.So.prototype,"gEQ","jt",0)
w(C.Sp.prototype,"galK","za",0)
w(t=C.Sv.prototype,"gaC7","AA",0)
w(t,"gaCS","H3",0)})();(function inheritance(){var w=a.mixinHard,v=a.inheritMany,u=a.inherit
v(A.T,[C.t4,C.aCo])
v(A.iE,[C.aCp,C.b7E,C.aMc,C.aMd,C.aLX,C.aMa,C.aZS,C.aZP,C.aZG,C.aZE,C.ajN,C.b7T,C.b_r,C.b_q,C.b8r,C.b8u,C.b8t])
v(A.L,[C.t3,C.NB,C.Qo,C.Sm,C.L1,C.L3,C.L4])
v(A.N,[C.acZ,C.NC,C.agD,C.Sn,C.aha,C.Sp,C.Sv])
v(A.oq,[C.b7D,C.aM1,C.aM7,C.aM8,C.aM0,C.aM2,C.aM3,C.aM4,C.aM5,C.aM6,C.aLY,C.aM9,C.aLZ,C.aM_,C.aZV,C.aZH,C.aZI,C.aZJ,C.aZK,C.aZQ,C.aZR,C.aZT,C.aZF,C.aZL,C.aZM,C.aZN,C.aZO,C.b7M,C.b7N,C.b7O,C.b7P,C.b8n,C.b7S,C.b7Q,C.b7R,C.b_t,C.b_u,C.b7X,C.b8o,C.b8p,C.b8s,C.b8q])
v(A.qC,[C.aMb,C.aZU,C.b_s])
u(C.Qp,C.agD)
v(A.a6,[C.ad0,C.aai,C.D1])
u(C.So,C.aha)
w(C.agD,H.hw)
w(C.aha,H.hw)})()
A.EB(b.typeUniverse,JSON.parse('{"NB":{"L":[],"d":[],"e":[]},"Qo":{"L":[],"d":[],"e":[]},"Sm":{"L":[],"d":[],"e":[]},"t3":{"L":[],"d":[],"e":[]},"acZ":{"N":["t3"]},"NC":{"N":["NB"]},"Qp":{"N":["Qo"]},"Sn":{"N":["Sm"]},"ad0":{"a6":[],"d":[],"e":[]},"L1":{"L":[],"d":[],"e":[]},"So":{"N":["L1"]},"aai":{"a6":[],"d":[],"e":[]},"L3":{"L":[],"d":[],"e":[]},"Sp":{"N":["L3"]},"L4":{"L":[],"d":[],"e":[]},"Sv":{"N":["L4"]},"D1":{"a6":[],"d":[],"e":[]}}'))
var y={a:"https://findfooddelivery-backend.onrender.com/deliveries/offers/",d:"https://findfooddelivery-backend.onrender.com/riders/me/verification"}
var x=(function rtii(){var w=A.aJ
return{d:w("kJ"),f:w("qY"),V:w("J<dj>"),J:w("J<kM>"),A:w("J<eS>"),s:w("J<r>"),p:w("J<d>"),D:w("Y<aF<r,@>>"),l:w("Y<eS>"),j:w("Y<@>"),P:w("aF<r,@>"),W:w("eS"),L:w("t4"),N:w("r"),O:w("y<r>"),q:w("u_"),y:w("M"),z:w("@"),S:w("A"),g:w("Y<@>?"),Q:w("ry?"),H:w("~")}})();(function constants(){var w=a.makeConstList
D.Km=new I.yL("Rider",null)
D.ND=new A.kM("customer","Customer","Directions and delivery updates")
D.Rc=new A.a1(0,0,0,40)
D.Re=new A.a1(0,0,12,0)
D.RR=new A.a1(15,0,0,0)
D.ve=new A.a1(16,12,16,12)
D.RW=new A.a1(16,12,16,8)
D.Se=new A.a1(20,0,20,14)
D.SW=new I.zP(44,null)
D.Uk=new A.a4(61734,"MaterialIcons",null,!1)
D.T1=new A.d5(D.Uk,"No deliveries right now","Stay online \u2014 new jobs appear as orders come in.",null,null,null)
D.T5=new A.d5(B.dP,"You're offline","Go online to start seeing available deliveries.",null,null,null)
D.T6=new A.d5(B.dP,"No deliveries yet","Accept a job from Available tab to get started.",null,null,null)
D.mV=new A.x(!0,null,null,"PlusJakartaSans",null,null,28,B.C,null,-0.8,null,null,1.15,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aja=new A.am("Available jobs",null,D.mV,null,null,B.a1,null,null,null,null,null)
D.ajH=new A.am("Tap a job to accept it",null,B.IW,null,null,null,null,null,null,null,null)
D.a1V=w([D.aja,B.bu,D.ajH],x.p)
D.Px=new A.lG(B.V,B.e,B.f,B.q,null,B.k,null,0,D.a1V,null)
D.Te=new A.ds(1,B.b5,D.Px,null)
D.U8=new A.a4(61112,"MaterialIcons",null,!1)
D.Um=new A.a4(61838,"MaterialIcons",null,!1)
D.w8=new A.a4(61958,"MaterialIcons",null,!1)
D.V4=new A.a4(63510,"MaterialIcons",null,!1)
D.VY=new A.aW(F.jf,18,B.x,null,null)
D.Wp=new A.aW(B.fA,18,B.E,null,null)
D.Ww=new A.aW(B.fB,16,B.y,null,null)
D.Wz=new A.aW(B.V2,16,B.E,null,null)
D.WL=new A.aW(B.cm,16,B.m,null,null)
D.WV=new A.aW(B.lx,18,B.x,null,null)
D.WZ=new A.aW(B.fD,18,B.E,null,null)
D.X8=new A.aW(B.cm,20,B.aF,null,null)
D.Xa=new A.aW(F.wK,18,null,null,null)
D.Ud=new A.a4(61495,"MaterialIcons",null,!1)
D.auf=new A.a4(63268,"MaterialIcons",null,!1)
D.TM=new A.hu(D.Ud,"Available",0)
D.TN=new A.hu(B.dP,"My Deliveries",0)
D.TH=new A.hu(B.jb,"Earnings",0)
D.a1H=w([D.TM,D.TN,D.TH,B.vW],A.aJ("J<hu>"))
D.a4Q={motorbike:0,bicycle:1,car:2,on_foot:3}
D.Cy=new A.bA(D.a4Q,["Motorbike","Bicycle","Car","On foot"],A.aJ("bA<r,r>"))
D.ajf=new A.am("My deliveries",null,D.mV,null,null,null,null,null,null,null,null)
D.a5Z=new A.Z(B.oH,D.ajf,null)
D.Rv=new A.a1(0,60,0,0)
D.a62=new A.Z(D.Rv,B.bX,null)
D.a9c=new C.L3(null)
D.WJ=new A.aW(B.pG,18,B.x,null,null)
D.ak4=new A.am("New delivery available!",null,G.IG,null,null,null,null,null,null,null,null)
D.a1x=w([D.WJ,B.ab,D.ak4],x.p)
D.a9i=new A.j_(B.aJ,B.e,B.f,B.i,null,B.k,null,0,D.a1x,null)
D.akr=new A.am("Could not open maps.",null,null,null,null,null,null,null,null,null,null)
D.Ic=new A.fO(D.akr,null,null,null,null,null,null,null,null,null,null,null,null,B.ae,!1,null,null,null,B.B,null)
D.aiR=new A.am("Delivery complete. Nice work!",null,B.b6,null,null,null,null,null,null,null,null)
D.act=new A.fO(D.aiR,B.E,null,null,null,null,null,null,null,null,null,null,null,B.ae,!1,null,null,null,B.B,null)
D.akm=new A.am("This order does not have a delivery destination.",null,null,null,null,null,null,null,null,null,null)
D.Id=new A.fO(D.akm,null,null,null,null,null,null,null,null,null,null,null,null,B.ae,!1,null,null,null,B.B,null)
D.mU=new A.x(!0,null,null,"PlusJakartaSans",null,null,12,B.av,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ag9=new A.x(!0,B.E,null,null,null,null,22,B.ds,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.mW=new A.x(!0,null,null,"PlusJakartaSans",null,null,16,B.z,null,-0.1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.k5=new A.x(!0,null,null,"PlusJakartaSans",null,null,13,B.a2,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aiL=new A.am("Earned today",null,D.k5,null,null,null,null,null,null,null,null)
D.aiS=new A.am("Release this job",null,null,null,null,null,null,null,null,null,null)
D.aiY=new A.am("It goes back to the available jobs for another rider. You can release up to 2 jobs a day, and never after collecting the food.",null,null,null,null,null,null,null,null,null,null)
D.aj9=new A.am("Complete with customer's code",null,null,null,null,null,null,null,null,null,null)
D.ajR=new A.am("Decline",null,null,null,null,null,null,null,null,null,null)
D.ajZ=new A.am("Earnings",null,D.mV,null,null,null,null,null,null,null,null)
D.ak2=new A.am("Recent deliveries",null,B.IR,null,null,null,null,null,null,null,null)
D.akv=new A.am("Profile",null,D.mV,null,null,null,null,null,null,null,null)
D.akJ=new A.am("Keep job",null,null,null,null,null,null,null,null,null,null)
D.akP=new A.am("Release",null,B.k4,null,null,null,null,null,null,null,null)
D.akY=new A.am("Add your MoMo to get paid",null,null,null,null,null,null,null,null,null,null)
D.al_=new A.am("Accept delivery",null,null,null,null,null,null,null,null,null,null)
D.al3=new A.am("Add",null,null,null,null,null,null,null,null,null,null)
D.an_=new A.y("rider-add-payout",x.O)
D.an5=new A.y("verify-licence",x.O)
D.anL=new A.y("rider-owed",x.O)
D.anV=new A.y("verification-add-phone",x.O)
D.aob=new A.y("verify-plate",x.O)
D.aof=new A.y("rider-offers",x.O)
D.aoj=new A.y("verify-card",x.O)
D.aoH=new A.y("verify-emergency-name",x.O)
D.ap9=new A.y("verify-submit",x.O)
D.apq=new A.y("confirm-release",x.O)
D.apz=new A.y("rider-payout-card",x.O)
D.apT=new A.y("rider-online-toggle",x.O)
D.aqk=new A.y("verify-emergency-phone",x.O)
D.aqC=new A.y("verification-pending",x.O)
D.aqH=new A.y("verification-rejected",x.O)
D.arb=new A.y("settings-rider-payout",x.O)
D.ard=new A.y("rider-today-earnings",x.O)
D.arJ=new C.NB(null)
D.Vn=new A.a4(983663,"MaterialIcons",null,!1)
D.arN=new C.D1(B.aF,D.Vn,"Riders are checked before their first job","It keeps customers and restaurants safe. It takes a few minutes to fill in.",null)
D.at6=new C.Qo(null)
D.atq=new C.Sm(null)
D.ats=new C.ad0(null)})()};
(a=>{a["QWl1EUbWuAGmYGn8hMTjjkdZK+M="]=a.current})($__dart_deferred_initializers__);