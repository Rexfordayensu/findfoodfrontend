((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,E,G,I,K,C={
btl(d){var w,v,u,t,s,r,q=J.a7(d)
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
r=A.cv(q.h(d,"average_rating"))
if(r==null)r=null
q=q.h(d,"recent_deliveries")
if(q==null)q=[]
q=J.eo(x.j.a(q),new C.aEW(),x.L)
q=A.ag(q,q.$ti.i("aK.E"))
return new C.aEV(w,v,u,t,s,r,q)},
ty:function ty(d,e,f,g){var _=this
_.a=d
_.b=e
_.d=f
_.e=g},
aEV:function aEV(d,e,f,g,h,i,j){var _=this
_.c=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j},
aEW:function aEW(){},
bHa(){return new C.tx(null)},
tx:function tx(d){this.a=d},
aeo:function aeo(){this.d=0
this.c=this.a=null},
baT:function baT(d){this.a=d},
baS:function baS(d,e){this.a=d
this.b=e},
Ow:function Ow(d){this.a=d},
Ox:function Ox(d){var _=this
_.d=d
_.f=_.e=!0
_.w=_.r=null
_.x=""
_.y=null
_.z=0
_.c=_.a=null},
aOW:function aOW(d,e){this.a=d
this.b=e},
aP1:function aP1(d,e){this.a=d
this.b=e},
aP2:function aP2(d,e){this.a=d
this.b=e},
aOV:function aOV(d,e){this.a=d
this.b=e},
aP6:function aP6(d){this.a=d},
aP7:function aP7(){},
aOX:function aOX(d){this.a=d},
aOY:function aOY(d,e){this.a=d
this.b=e},
aOZ:function aOZ(d,e){this.a=d
this.b=e},
aP_:function aP_(d){this.a=d},
aP0:function aP0(d,e){this.a=d
this.b=e},
aOS:function aOS(d,e){this.a=d
this.b=e},
aOR:function aOR(d){this.a=d},
aP4:function aP4(d){this.a=d},
aP3:function aP3(d,e){this.a=d
this.b=e},
aP5:function aP5(d){this.a=d},
aOT:function aOT(d,e){this.a=d
this.b=e},
aOU:function aOU(d,e){this.a=d
this.b=e},
Rp:function Rp(d){this.a=d},
Rq:function Rq(d,e,f){var _=this
_.d=d
_.e=!0
_.f=""
_.dO$=e
_.i2$=f
_.c=_.a=null},
b21:function b21(d){this.a=d},
b1O:function b1O(d){this.a=d},
b1P:function b1P(d,e){this.a=d
this.b=e},
b1Q:function b1Q(d,e){this.a=d
this.b=e},
b1R:function b1R(d){this.a=d},
b1Z:function b1Z(d){this.a=d},
b1X:function b1X(d){this.a=d},
b1Y:function b1Y(d){this.a=d},
b2_:function b2_(d,e){this.a=d
this.b=e},
b1W:function b1W(d){this.a=d},
b1N:function b1N(d,e,f){this.a=d
this.b=e
this.c=f},
b1M:function b1M(d,e,f){this.a=d
this.b=e
this.c=f},
b1L:function b1L(d){this.a=d},
b20:function b20(d){this.a=d},
b1S:function b1S(d,e){this.a=d
this.b=e},
b1T:function b1T(d,e){this.a=d
this.b=e},
b1U:function b1U(d,e){this.a=d
this.b=e},
b1V:function b1V(d,e){this.a=d
this.b=e},
Tq:function Tq(d){this.a=d},
Tr:function Tr(){var _=this
_.e=_.d=null
_.f=!0
_.c=_.a=null},
bb0:function bb0(d){this.a=d},
bb1:function bb1(d,e){this.a=d
this.b=e},
bb2:function bb2(d,e){this.a=d
this.b=e},
bb3:function bb3(d){this.a=d},
aes:function aes(d){this.a=d},
bbF:function bbF(d){this.a=d},
afc:function afc(d){this.a=d},
bcV:function bcV(d){this.a=d},
ai8:function ai8(){},
Xg(d){var w=0,v=A.q(x.l),u,t,s
var $async$Xg=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bV("GET",A.as("https://findfooddelivery-backend.onrender.com/deliveries/available",0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$Xg)
case 3:s=f
t=s.b
if(t===200){t=J.eo(A.f4(s),new C.als(),x.W)
t=A.ag(t,t.$ti.i("aK.E"))
u=t
w=1
break}throw A.i(A.ah("Failed to load deliveries ("+t+")"))
case 1:return A.o(u,v)}})
return A.p($async$Xg,v)},
Xr(d){var w=0,v=A.q(x.P),u,t,s,r
var $async$Xr=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bV("GET",A.as("https://findfooddelivery-backend.onrender.com/riders/me/analytics",0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$Xr)
case 3:s=f
r=A.bg(s)
if(s.b===200){u=r
w=1
break}t=J.B(r,"detail")
throw A.i(A.ah(t==null?"Failed to load analytics":t))
case 1:return A.o(u,v)}})
return A.p($async$Xr,v)},
XA(d,e){var w=0,v=A.q(x.H),u,t
var $async$XA=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aH().bk("PUT",A.as("https://findfooddelivery-backend.onrender.com/riders/me/online",0,null),A.L(["Content-Type","application/json","Authorization","Bearer "+d],u,u),B.T.bG(A.L(["online",e],u,x.y),null),null),$async$XA)
case 2:t=g
if(t.b!==200)throw A.i(A.ah(A.bq(t,"Could not change your status")))
return A.o(null,v)}})
return A.p($async$XA,v)},
alv(d){var w=0,v=A.q(x.D),u,t,s
var $async$alv=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bV("GET",A.as("https://findfooddelivery-backend.onrender.com/deliveries/offers",0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$alv)
case 3:s=f
if(s.b===200){u=A.dL(A.f4(s),!0,x.P)
w=1
break}throw A.i(A.ah(A.bq(s,"Could not load requests")))
case 1:return A.o(u,v)}})
return A.p($async$alv,v)},
akW(d,e){var w=0,v=A.q(x.W),u,t,s
var $async$akW=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bk("POST",A.as(y.a+e+"/accept",0,null),A.L(["Authorization","Bearer "+d],t,t),null,null),$async$akW)
case 3:s=g
if(s.b===200){u=A.BG(A.bg(s))
w=1
break}throw A.i(A.ah(A.bq(s,"Could not accept the delivery")))
case 1:return A.o(u,v)}})
return A.p($async$akW,v)},
ala(d,e){var w=0,v=A.q(x.H),u,t
var $async$ala=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aH().bk("POST",A.as(y.a+e+"/decline",0,null),A.L(["Authorization","Bearer "+d],u,u),null,null),$async$ala)
case 2:t=g
if(t.b!==200)throw A.i(A.ah(A.bq(t,"Could not decline")))
return A.o(null,v)}})
return A.p($async$ala,v)},
Xs(d){var w=0,v=A.q(x.P),u,t,s
var $async$Xs=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bV("GET",A.as(y.d,0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$Xs)
case 3:s=f
if(s.b===200){u=A.bg(s)
w=1
break}throw A.i(A.ah(A.bq(s,"Could not load your verification")))
case 1:return A.o(u,v)}})
return A.p($async$Xs,v)},
amG(d,e){var w=0,v=A.q(x.P),u,t,s
var $async$amG=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aH().bk("PUT",A.as(y.d,0,null),A.L(["Content-Type","application/json","Authorization","Bearer "+d],t,t),B.T.bG(e,null),null),$async$amG)
case 3:s=g
if(s.b===200){u=A.bg(s)
w=1
break}throw A.i(A.ah(A.bq(s,"Could not send your details")))
case 1:return A.o(u,v)}})
return A.p($async$amG,v)},
amM(d,e,f,g){var w=0,v=A.q(x.y),u,t,s,r,q,p
var $async$amM=A.m(function(h,i){if(h===1)return A.n(i,v)
for(;;)switch(w){case 0:s=$.aH()
r=A.as("https://findfooddelivery-backend.onrender.com/riders/me/location",0,null)
q=x.N
p=A.L(["Authorization","Bearer "+d,"Content-Type","application/json"],q,q)
q=A.G(q,x.i)
q.n(0,"lat",f)
q.n(0,"lng",g)
if(e!=null)q.n(0,"heading",e)
w=3
return A.h(s.bk("PUT",r,p,B.T.bG(q,null),null),$async$amM)
case 3:t=i
if(t.b===200){u=J.f(J.B(A.bg(t),"sharing"),!0)
w=1
break}throw A.i(A.ah(A.bq(t,"Could not share your location")))
case 1:return A.o(u,v)}})
return A.p($async$amM,v)},
als:function als(){},
Mv:function Mv(d,e){this.a=d
this.b=e},
LS:function LS(d,e){var _=this
_.a=d
_.r=_.f=_.e=_.d=_.c=_.b=null
_.w=!1
_.p4$=0
_.R8$=e
_.rx$=_.RG$=0},
aF2:function aF2(d){this.a=d},
aF1:function aF1(){},
aF_:function aF_(d){this.a=d},
aF0:function aF0(d){this.a=d},
LT:function LT(d,e){this.c=d
this.a=e},
Ts:function Ts(d,e,f){var _=this
_.d=d
_.e=null
_.f=-1
_.dO$=e
_.i2$=f
_.c=_.a=null},
bb9:function bb9(d,e){this.a=d
this.b=e},
bb7:function bb7(d,e){this.a=d
this.b=e},
bb8:function bb8(d){this.a=d},
bba:function bba(d,e){this.a=d
this.b=e},
abJ:function abJ(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
b2A:function b2A(){},
b2B:function b2B(d,e){this.a=d
this.b=e},
b2z:function b2z(d){this.a=d},
b2C:function b2C(d){this.a=d},
b2D:function b2D(d){this.a=d},
aiI:function aiI(){},
LV:function LV(d){this.a=d},
Tt:function Tt(){this.c=this.a=this.d=null},
bbe:function bbe(d,e){this.a=d
this.b=e},
LW:function LW(d,e,f){this.c=d
this.d=e
this.a=f},
Tz:function Tz(d,e,f,g,h){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x="motorbike"
_.y=!1
_.c=_.a=null},
bbG:function bbG(d){this.a=d},
bbH:function bbH(d){this.a=d},
bbJ:function bbJ(){},
bbM:function bbM(d,e,f){this.a=d
this.b=e
this.c=f},
bbK:function bbK(d,e){this.a=d
this.b=e},
bbL:function bbL(d,e){this.a=d
this.b=e},
bbI:function bbI(d,e){this.a=d
this.b=e},
DM:function DM(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bvB(d,e,f,g){var w,v,u,t,s,r,q,p,o,n=null,m=e.length,l="",k=n
if(m!==0){v=0
for(;;){if(!(v<m)){w=0
break}if(e.charCodeAt(v)===64){l=B.d.ae(e,0,v)
w=v+1
break}++v}if(w<m&&e.charCodeAt(w)===91){for(u=w,t=-1;u<m;++u){s=e.charCodeAt(u)
if(s===37&&t<0){r=B.d.eg(e,"25",u+1)?u+2:u
t=u
u=r}else if(s===93)break}if(u===m)throw A.i(A.d0("Invalid IPv6 host entry.",e,w))
q=t<0?u:t
A.buj(e,w+1,q);++u
if(u!==m&&e.charCodeAt(u)!==58)throw A.i(A.d0("Invalid end of authority",e,u))}else u=w
for(;u<m;++u)if(e.charCodeAt(u)===58){p=B.d.cb(e,u+1)
k=p.length!==0?A.fN(p,n):n
break}o=B.d.ae(e,w,u)}else o=n
return A.iI(n,o,n,A.a(f.split("/"),x.s),k,g,d,l)}},D,H,F
J=c[1]
A=c[0]
B=c[2]
E=c[9]
G=c[17]
I=c[10]
K=c[14]
C=a.updateHolder(c[4],C)
D=c[18]
H=c[8]
F=c[12]
C.ty.prototype={}
C.aEV.prototype={}
C.tx.prototype={
L(){return new C.aeo()}}
C.aeo.prototype={
V(){var w,v
this.aa()
w=this.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)$.ajY().Nw(0,v)},
j(){var w=$.ajY(),v=w.c
if(v!=null)v.ak(0)
w.b=w.c=null
w.BB()
w.pS(D.k1)
this.a2()},
t(d){var w=null,v=this.d
return A.d2(w,w,new A.rp([D.atA,D.auY,D.avn,D.avp][v],w),A.au_(0,w,w,v,D.a37,w,new C.baT(this)),w,!0,w,w)}}
C.Ow.prototype={
L(){return new C.Ox(A.a([],x.A))}}
C.Ox.prototype={
Hb(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$Hb=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=r.c
m.toString
q=A.af(m,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.Xs(q),$async$Hb)
case 7:p=e
if(r.c==null){w=1
break}m=r.w
o=J.f(m==null?null:J.B(m,"can_work"),!1)
r.p(new C.aOW(r,p))
if(o&&J.f(J.B(p,"can_work"),!0))r.j6()
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
return A.p($async$Hb,v)},
Ix(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$Ix=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=!r.f
r.p(new C.aP1(r,m))
o=r.c
o.toString
q=A.af(o,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.XA(q,m),$async$Ix)
case 7:t=2
w=6
break
case 4:t=3
l=s.pop()
p=A.a2(l)
if(r.c==null){w=1
break}r.p(new C.aP2(r,m))
r.c.U(x.q).f.bQ(A.d8(null,null,null,null,null,B.B,null,A.j(A.b9(p),null,null,null,null,null,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Ix,v)},
Ha(d){return this.aAa(d)},
aAa(d){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p
var $async$Ha=A.m(function(e,f){if(e===1){t.push(f)
w=u}for(;;)switch(w){case 0:u=3
w=6
return A.h(C.Xr(d),$async$Ha)
case 6:r=f
if(s.c!=null)s.p(new C.aOV(s,r))
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
return A.p($async$Ha,v)},
o9(d){return this.aCo(d)},
aCo(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$o9=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a3(r).length===0){t.c.U(x.q).f.bQ(D.IK)
w=1
break}w=3
return A.h(A.uH(C.bvB("https","www.google.com","/maps/dir/",A.L(["api","1","destination",r],x.N,x.z)).giA(),B.m_,null),$async$o9)
case 3:if(!f&&t.c!=null)t.c.U(x.q).f.bQ(D.IJ)
case 1:return A.o(u,v)}})
return A.p($async$o9,v)},
V(){var w,v,u=this
u.aa()
u.j6()
u.Hb()
u.y=A.ib(B.oM,new C.aP6(u))
w=u.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)C.XA(v,!0).dD(new C.aP7())},
j(){var w=this.y
if(w!=null)w.ak(0)
this.a2()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d)
if(p.c==null){w=1
break}q.p(new C.aOX(q))
l=p.c
l.toString
q.Ha(l)
t=4
l=p.c
l.toString
w=7
return A.h(C.Xg(l),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.aOY(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a2(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.aOZ(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.aP_(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
HB(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$HB=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(!r.f){w=1
break}o=r.c
o.toString
q=A.af(o,!1,x.d)
if(q.c==null){w=1
break}t=4
o=q.c
o.toString
w=7
return A.h(C.Xg(o),$async$HB)
case 7:p=e
if(r.c==null){w=1
break}if(J.ba(p)>r.z)r.c.U(x.q).f.bQ(A.d8(null,null,null,B.m,B.dh,B.B,null,D.aaQ,null,B.af,null,null,null,B.ba,null,null,null,new A.bx(A.a_(12),B.I),null,null))
r.p(new C.aP0(r,p))
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
return A.p($async$HB,v)},
FA(d){return this.ani(d)},
ani(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l,k,j
var $async$FA=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=r.c
k.toString
q=A.af(k,!1,x.d)
t=4
k=q.c
k.toString
n=""+d.a
w=7
return A.h(E.zs(k,"/deliveries/"+n+"/accept","Could not accept this delivery.",null),$async$FA)
case 7:p=f
$.ajY().fZ(0)
if(r.c==null){w=1
break}r.p(new C.aOS(r,d))
k=r.c.U(x.q).f
m=p.ok
if(m==null)m="in My deliveries"
k.bQ(A.d8(null,null,null,B.F,null,B.B,null,A.j("Delivery #"+n+" accepted. Your pickup code is "+m+" \u2014 give it to the restaurant when you collect.",null,null,null,null,B.b6,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
t=2
w=6
break
case 4:t=3
j=s.pop()
o=A.a2(j)
k=r.c
if(k==null){w=1
break}k.U(x.q).f.bQ(A.d8(null,null,null,B.H,null,B.B,null,A.j(A.b9(o),null,null,null,null,B.b6,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$FA,v)},
t(d){var w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.w
if(l!=null&&J.f(J.B(l,"can_work"),!1)){if(d.df(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b0:B.aQ
return A.d2(m,w,A.dR(!0,new C.LW(l,new C.aP4(n),m),B.X,!0),m,m,!1,m,m)}if(d.df(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b0:B.aQ
v=A.af(d,!0,x.d).f
if(v==null)v=""
if(n.f)if(J.d5(n.d))u=m
else{u=J.ba(n.d)
t=J.ba(n.d)===1?"":"s"
t=""+u+" job"+t+" near you right now."
u=t}else u="You're offline. Go online to get delivery jobs."
u=A.IP(v,G.vF,"rider",u)
if(n.f)v=B.F.N(0.12)
else v=A.c(d).ax.a===B.c?B.au:B.at
t=A.a_(20)
if(n.f)s=B.F.N(0.5)
else s=A.c(d).ax.a===B.c?B.E:B.G
s=A.aZ(s,B.n,1)
if(n.f)r=B.F
else r=A.c(d).ax.a===B.c?B.R:B.Q
r=A.ef(m,m,m,B.Z,new A.Z(r,m,m,m,m,m,B.as),B.cz,m,8,m,m,8)
q=n.f
p=q?"Online":"Offline"
if(q)q=B.F
else q=A.c(d).ax.a===B.c?B.R:B.Q
o=x.p
t=A.V(A.a([D.U4,B.aB,A.ch(m,A.ef(m,A.V(A.a([r,B.bN,A.j(p,m,m,m,m,A.t(m,m,q,m,m,m,m,m,m,m,m,13,m,m,B.a1,m,m,!0,m,m,m,m,m,m,m,m),m,m,m,m)],o),B.i,m,B.e,B.f,0,m),m,B.Z,new A.Z(v,m,s,t,m,m,B.o),B.cz,m,m,m,F.ln,m),B.L,!1,D.arI,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,n.gaIg(),m,m,m,m,m,m,!1,B.aa),B.ae,F.qN],o),B.i,m,B.bK,B.f,0,m)
s=n.gwr()
v=n.S0(F.jn,""+J.ba(n.d),"Available")
q=n.r
r=q==null?m:q.f
r=n.S0(F.jl,""+(r==null?0:r),"Completed today")
q=n.r
q=q==null?m:q.e
v=A.bw(A.dE(A.a([v,r,n.S0(B.jj,A.bI(q==null?0:q),"Earned today")],o),m,m,B.lo,m,B.aJ,!1),80,m)
if(!n.f)r=D.TV
else if(n.e)r=B.bY
else{r=n.x
if(r.length!==0)r=new A.d6(B.b7,"Connection failed",r,"Retry",s,m)
else r=J.d5(n.d)?D.TR:A.ex(A.rO(m,new C.aP5(n),J.ba(n.d),G.vH),B.m,s)}return A.d2(m,w,A.dR(!0,A.U(A.a([u,new A.a0(G.vI,t,m),B.a3,new C.LT(s,m),v,B.a6,A.ae(r,1)],o),B.q,m,B.e,B.f,0,B.k),B.X,!0),m,m,!1,m,m)},
S0(d,e,f){var w,v,u,t,s,r=null,q=this.c
q.toString
q=A.bS(q)
w=A.a_(14)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.G,B.n,1)
t=A.ao(d,B.m,r,r,20)
s=this.c
s.toString
v=x.p
return A.a3(r,A.V(A.a([t,B.ae,A.U(A.a([A.j(e,r,r,r,r,A.t(r,r,A.c(s).ax.a===B.c?B.t:B.r,r,r,r,r,r,r,r,r,18,r,r,B.C,r,r,!0,r,r,r,r,r,r,r,r),r,r,r,r),A.j(f,r,r,r,r,D.n6,r,r,r,r)],v),B.q,r,B.aY,B.f,0,B.k)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.Z(q,r,u,w,r,r,B.o),r,r,r,D.S_,D.vz,r,r,r)},
ari(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j=l.c
j.toString
j=A.bS(j)
w=A.a_(16)
v=A.aZ(B.m.N(0.25),B.n,1)
u=""+d.a
t=x.p
s=A.V(A.a([A.j("Order #"+u,k,k,k,k,D.n8,k,k,k,k),A.j(A.bI(d.b),k,k,k,k,D.n8.bj(B.m),k,k,k,k)],t),B.i,k,B.bK,B.f,0,k)
r=A.a3(k,D.XO,B.j,k,k,new A.Z(B.m.N(0.12),k,k,k,k,k,B.as),k,32,k,k,k,k,k,32)
q=l.c
q.toString
p=A.j("Pickup",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.aw,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
o=d.f
q=o==null?"Restaurant":o
o=l.c
o.toString
r=A.V(A.a([r,B.aB,A.ae(A.U(A.a([p,A.j(q,k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,14,k,k,B.aw,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t),B.i,k,B.e,B.f,0,k)
q=l.c
q.toString
p=A.a3(k,k,B.j,A.c(q).ax.a===B.c?B.E:B.G,k,k,k,20,k,k,k,k,k,2)
o=A.a3(k,D.XC,B.j,k,k,new A.Z(B.F.N(0.12),k,k,k,k,k,B.as),k,32,k,k,k,k,k,32)
n=l.c
n.toString
q=A.j("Dropoff",k,k,k,k,A.t(k,k,A.c(n).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.aw,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
if(d.gDt())n="Pinned location"
else{n=d.z
n.toString
n=B.d.a3(n)}m=l.c
m.toString
q=A.a([o,B.aB,A.ae(A.U(A.a([q,A.j(n,k,2,B.a2,k,A.t(k,k,A.c(m).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,14,k,k,B.aw,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gac0())B.b.H(q,A.a([B.ac,new A.qO(D.wv,"Directions","Directions to the drop-off",new C.aOT(l,d),new A.y("available-directions-"+u,x.O))],t))
u=A.a([new A.a0(B.bb,A.U(A.a([s,B.az,r,new A.a0(D.SE,p,k),A.V(q,B.i,k,B.e,B.f,0,k)],t),B.q,k,B.e,B.f,0,B.k),k)],t)
if(d.cy.length!==0){s=l.c
s.toString
B.b.H(u,A.a([A.hS(A.c(s).ax.a===B.c?B.E:B.G,1,k),new A.a0(D.SJ,new E.wY(d,!0,k),k)],t))}t=l.c
t.toString
u.push(A.hS(A.c(t).ax.a===B.c?B.E:B.G,1,k))
u.push(new A.a0(B.ba,A.bw(A.ZU(D.WZ,k,D.amJ,new C.aOU(l,d)),44,1/0),k))
return A.a3(k,A.U(u,B.i,k,B.e,B.f,0,B.k),B.j,k,k,new A.Z(j,k,v,w,k,k,B.o),k,k,k,B.fv,k,k,k,k)}}
C.Rp.prototype={
L(){return new C.Rq(A.a([],x.A),null,!1)}}
C.Rq.prototype={
o9(d){return this.aCp(d)},
aCp(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$o9=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a3(r).length===0){t.c.U(x.q).f.bQ(D.IK)
w=1
break}w=3
return A.h(A.uH(C.bvB("https","www.google.com","/maps/dir/",A.L(["api","1","destination",r],x.N,x.z)).giA(),B.m_,null),$async$o9)
case 3:if(!f&&t.c!=null)t.c.U(x.q).f.bQ(D.IJ)
case 1:return A.o(u,v)}})
return A.p($async$o9,v)},
V(){var w=this
w.aa()
w.j6()
w.j_(new C.b21(w))},
ws(d){return this.azY(d)},
j6(){return this.ws(!1)},
azY(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j
var $async$ws=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=q.c
k.toString
p=A.af(k,!1,x.d)
if(p.c==null){w=1
break}k=!d
if(k)q.p(new C.b1O(q))
t=4
m=p.c
m.toString
w=7
return A.h(A.lV(m),$async$ws)
case 7:o=f
if(q.c==null){r=[1]
w=5
break}q.p(new C.b1P(q,o))
r.push(6)
w=5
break
case 4:t=3
j=s.pop()
n=A.a2(j)
if(q.c==null||d){r=[1]
w=5
break}q.p(new C.b1Q(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null&&k)q.p(new C.b1R(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$ws,v)},
Bg(d){return this.aEu(d)},
aEu(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$Bg=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
w=3
return A.h(A.fd(null,null,!0,null,new C.b1Z(d),n,null,!0,x.y),$async$Bg)
case 3:if(f!==!0||r.c==null){w=1
break}t=5
n=r.c
n.toString
n=A.af(n,!1,x.d).c
n.toString
p=""+d.a
w=8
return A.h(E.zs(n,"/deliveries/"+p+"/release","Could not release this delivery.",null),$async$Bg)
case 8:if(r.c==null){w=1
break}r.p(new C.b2_(r,d))
n=r.c.U(x.q).f
n.KH()
n.bQ(A.d8(null,null,null,null,null,B.B,null,A.j("Order #"+p+" released to other riders.",null,null,null,null,null,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
t=2
w=7
break
case 5:t=4
m=s.pop()
q=A.a2(m)
n=r.c
if(n==null){w=1
break}n=n.U(x.q).f
n.KH()
n.bQ(A.d8(null,null,null,B.H,null,B.B,null,A.j(A.b9(q),null,null,null,null,B.b6,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=7
break
case 4:w=2
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Bg,v)},
FV(d){return this.aqc(d)},
aqc(d){var w=0,v=A.q(x.H),u=this,t,s
var $async$FV=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=u.c
s.toString
s=A.af(s,!1,x.d).c
s.toString
t=u.c
t.toString
w=2
return A.h(E.ajJ(t,"Complete delivery",null,"Ask the customer for the 4-digit delivery code shown in their FindFood app. Hand over the food once the code is accepted.",new C.b1N(u,s,d),"Enter the customer's code"),$async$FV)
case 2:if(f&&u.c!=null)u.c.U(x.q).f.bQ(D.ae2)
return A.o(null,v)}})
return A.p($async$FV,v)},
t(d){var w,v=this,u=null
if(v.e)w=B.bY
else{w=v.f
if(w.length!==0)w=new A.d6(B.b7,"Failed to load",w,"Retry",v.gwr(),u)
else w=J.d5(v.d)?D.TW:A.ex(A.rO(u,new C.b20(v),J.ba(v.d),G.vD),B.m,v.gwr())}return A.d2(u,u,A.dR(!0,A.U(A.a([D.a7x,D.avz,A.ae(w,1)],x.p),B.q,u,B.e,B.f,0,B.k),B.X,!0),u,u,!1,u,u)},
aAP(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="the restaurant",i=d.c,h=i==="out_for_delivery",g=l.c
g.toString
g=A.bS(g)
w=A.a_(16)
if(h)v=B.m.N(0.4)
else{v=l.c
v.toString
v=A.c(v).ax.a===B.c?B.E:B.G}v=A.aZ(v,B.n,1)
u=""+d.a
t=x.p
s=A.a([A.ae(A.j("Order #"+u,k,k,k,k,D.n8,k,k,k,k),1)],t)
if(i!=="cancelled"){r=d.f
if(r==null)r=j
B.b.H(s,A.a([E.bpV(new A.y("rider-chat-"+u,x.O),new C.b1S(l,d),"the customer or "+r),B.ac],t))}s.push(new A.CW(i,k))
s=A.a([A.V(s,B.i,k,B.e,B.f,0,k),B.aF,A.j(A.bI(d.b),k,k,k,k,D.kh.bj(B.m),k,k,k,k)],t)
r=d.z
if(r!=null||d.Q!=null){if(d.gDt())r="Pinned location"
else{r.toString
r=B.d.a3(r)}r=A.a([A.j(r,k,2,B.a2,k,D.kh,k,k,k,k)],t)
if(d.gDt()){q=l.c
q.toString
r.push(A.j("Shared from the customer's phone",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,12,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}r=A.a([D.Xs,B.ac,A.ae(A.U(r,B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gac0())B.b.H(r,A.a([B.ac,new A.qO(D.wv,"Directions","Directions to the drop-off",new C.b1T(l,d),new A.y("rider-directions-"+u,x.O))],t))
B.b.H(s,A.a([B.O,A.V(r,B.i,k,B.e,B.f,0,k)],t))}if(d.ch!=null)r=i==="pending"||i==="preparing"||i==="ready"
else r=!1
if(r&&d.ok!=null){r=x.O
q=d.ok
q.toString
p=d.f
if(p==null)p=j
i=i==="ready"?"The food is ready.":"The kitchen is still preparing it."
o=l.c
o.toString
n=A.j("In the bag",k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,13,k,k,B.a1,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
m=l.c
m.toString
o=A.c(m).ax.a===B.c?B.t:B.r
m=l.c
m.toString
m=A.c(m).ax.a===B.c?B.E:B.G
B.b.H(s,A.a([B.az,new A.IR("Pickup code",q,"Check the bag is labelled #"+u+" and has everything below, then give this code to "+p+". "+i,B.dd,new A.y("rider-pickup-code-"+u,r)),B.O,n,B.aF,new E.wY(d,!1,k),B.a3,A.bw(A.lp(D.Yd,new A.y("rider-release-"+u,r),D.akw,new C.b1U(l,d),A.nC(k,k,k,k,k,k,k,k,k,o,k,k,k,k,new A.bx(A.a_(12),B.I),new A.av(m,1,B.n,-1),k,k,B.Ji,k)),46,1/0)],t))}if(h)B.b.H(s,A.a([B.az,A.bw(A.ZU(D.XY,new A.y("rider-complete-"+u,x.O),D.akR,new C.b1V(l,d)),46,1/0)],t))
return A.a3(k,A.U(s,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.Z(g,k,v,w,k,k,B.o),k,k,k,B.fv,B.bb,k,k,k)}}
C.Tq.prototype={
L(){return new C.Tr()}}
C.Tr.prototype={
V(){this.aa()
this.j6()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d).c
if(p==null){w=1
break}q.p(new C.bb0(q))
t=4
w=7
return A.h(C.Xr(p),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.bb1(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a2(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.bb2(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bb3(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
t(d){var w,v,u,t,s,r,q=this,p=null,o=q.d,n=q.gwr(),m=x.p,l=A.a([D.alH,B.b1,D.aaK],m)
if(q.f&&o==null)l.push(D.a7B)
else{w=q.e
if(w!=null&&o==null)l.push(A.U(A.a([A.j(w,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.v:B.u,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),A.c2(B.e4,p,p,p,n,p,p)],m),B.i,p,B.e,B.f,0,B.k))
else if(o!=null){w=A.a_(16)
v=A.aZ(B.m.N(0.3),B.n,1)
u=A.bI(o.e)
u=A.j(u,D.at3,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.m:B.ap,p,p,p,p,p,p,p,p,36,p,p,B.C,p,p,!0,p,-1,p,p,p,p,p,p),p,p,p,p)
t=A.ao(D.Vi,A.c(d).ax.a===B.c?B.v:B.u,p,p,14)
s=o.f
r=s===1?"y":"ies"
w=A.a3(p,A.U(A.a([D.akp,B.aF,u,B.ag,A.V(A.a([t,B.bN,A.j(""+s+" deliver"+r+" completed today",p,p,p,p,D.n6.bj(A.c(d).ax.a===B.c?B.v:B.u),p,p,p,p)],m),B.i,p,B.e,B.f,0,p)],m),B.q,p,B.e,B.f,0,B.k),B.j,p,p,new A.Z(B.hz,p,v,w,p,p,B.o),p,p,p,p,B.d8,p,p,1/0)
v=A.V(A.a([q.HZ("This week",A.bI(o.r)),B.e2,q.HZ("This month",A.bI(o.w))],m),B.i,p,B.e,B.f,0,p)
u=q.HZ("All time",A.bI(o.c))
t=o.x
m=A.a([w,B.az,v,B.az,A.V(A.a([u,B.e2,q.HZ("Rating",t==null?"No ratings yet":"\u2605 "+B.h.ai(t,1))],m),B.i,p,B.e,B.f,0,p),B.aH,D.alL,B.az],m)
w=o.y
if(w.length===0)m.push(A.j("Completed deliveries will appear here.",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.R:B.Q,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p))
else B.b.H(m,new A.ax(w,q.gaEb(),A.an(w).i("ax<1,d>")))
B.b.H(l,m)}}return A.d2(p,p,A.dR(!0,A.ex(A.dE(l,p,p,B.av,p,B.V,!1),B.m,n),B.X,!0),p,p,!1,p,p)},
HZ(d,e){var w,v,u,t=null,s=this.c
s.toString
s=A.bS(s)
w=A.a_(14)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.G,B.n,1)
return A.ae(A.a3(t,A.U(A.a([A.j(d,t,t,t,t,D.n6,t,t,t,t),B.aI,A.j(e,t,t,t,t,D.n8,t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k),B.j,t,t,new A.Z(s,t,u,w,t,t,B.o),t,t,t,t,B.bb,t,t,t),1)},
aEc(d){var w,v,u,t,s,r=null,q=d.e,p=A.a([],x.s),o=d.b
if(o!=null)p.push(o)
if(q!=null)p.push(""+A.cg(q)+"/"+A.bE(q)+" "+B.d.dd(B.l.k(A.kE(q)),2,"0")+":"+B.d.dd(B.l.k(A.lr(q)),2,"0"))
w=B.b.b8(p," \xb7 ")
p=this.c
p.toString
p=A.bS(p)
o=A.a_(12)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.G,B.n,1)
t=A.j("Order #"+d.a,r,r,r,r,D.kh,r,r,r,r)
s=this.c
s.toString
v=x.p
return A.a3(r,A.V(A.a([A.ae(A.U(A.a([t,A.j(w,r,r,r,r,D.n6.bj(A.c(s).ax.a===B.c?B.R:B.Q),r,r,r,r)],v),B.q,r,B.e,B.f,0,B.k),1),A.j(A.bI(d.d),r,r,r,r,D.kh.TP(B.m,B.z),r,r,r,r)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.Z(p,r,u,o,r,r,B.o),r,r,r,B.bW,D.vz,r,r,r)}}
C.aes.prototype={
t(d){var w=null,v=x.p
return A.d2(w,w,A.dR(!0,A.dE(A.a([D.ame,B.aH,D.KX,B.dC,new A.uR("rider",A.a([new A.jb(K.pM,"Payout account","Where your delivery pay is sent",new C.bbF(d),w,D.at1)],v),w),B.aH,K.ri],v),w,w,B.av,w,B.V,!1),B.X,!0),w,w,!1,w,w)}}
C.afc.prototype={
t(d){var w=$.ajY()
return new A.mb(new C.bcV(w),null,w,null)}}
C.ai8.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a2()}}
C.Mv.prototype={
K(){return"SharingState."+this.b}}
C.LS.prototype={
Nw(d,e){var w,v=this
v.b=e
w=v.c
if(w!=null)w.ak(0)
v.c=A.ib(B.vi,new C.aF2(v))
v.fZ(0)},
fZ(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$fZ=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.b
if(n==null){w=1
break}t=4
w=7
return A.h(A.lV(n),$async$fZ)
case 7:q=f
p=J.bBa(q,new C.aF1())
w=p?8:10
break
case 8:w=11
return A.h(r.wE(),$async$fZ)
case 11:w=9
break
case 10:r.BB()
r.pS(D.k1)
case 9:t=2
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
Mg(){var w=0,v=A.q(x.H),u=this
var $async$Mg=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:u.BB()
w=2
return A.h(u.fZ(0),$async$Mg)
case 2:return A.o(null,v)}})
return A.p($async$Mg,v)},
wE(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n
var $async$wE=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(r.e!=null){w=1
break}t=4
w=7
return A.h($.mV().xZ(),$async$wE)
case 7:if(!e){p=r.pS(D.mQ)
u=p
w=1
break}w=8
return A.h($.mV().n7(),$async$wE)
case 8:q=e
w=q===B.ev?9:10
break
case 9:w=11
return A.h($.mV().nz(0),$async$wE)
case 11:q=e
case 10:if(q===B.ev||q===B.hW){p=r.pS(D.mQ)
u=p
w=1
break}r.e=$.mV().Xx(D.a3B).aRM(r.gaAK(),new C.aF_(r))
p=r.d
if(p!=null)p.ak(0)
r.d=A.ib(B.oL,new C.aF0(r))
r.pS(D.I4)
t=2
w=6
break
case 4:t=3
n=s.pop()
r.pS(D.mQ)
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$wE,v)},
aAL(d){this.f=d
this.aF4(d)},
Bn(d,e){return this.aG6(d,e)},
aF4(d){return this.Bn(d,!1)},
aG6(d,e){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$Bn=A.m(function(f,g){if(f===1){s.push(g)
w=t}for(;;)switch(w){case 0:l=q.b
if(l==null||q.w){w=1
break}o=new A.cl(Date.now(),0,!1)
if(!e){n=q.r
n=n!=null&&o.e5(n).a<6e6}else n=!1
if(n){w=1
break}q.w=!0
q.r=o
t=4
n=d.r
n=n>=0&&n<=360?n:null
w=7
return A.h(C.amM(l,n,d.a,d.b),$async$Bn)
case 7:p=g
if(!p){q.BB()
q.pS(D.k1)}r.push(6)
w=5
break
case 4:t=3
k=s.pop()
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
q.w=!1
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Bn,v)},
BB(){var w=this,v=w.e
if(v!=null)v.ak(0)
w.e=null
v=w.d
if(v!=null)v.ak(0)
w.f=w.d=null},
pS(d){if(this.a===d)return
this.a=d
this.T()}}
C.LT.prototype={
L(){return new C.Ts(B.eu,null,!1)}}
C.Ts.prototype={
V(){var w=this
w.aa()
w.jA()
w.j_(w.gFI())},
b5(){var w,v,u=this
u.ck()
w=u.c
w.toString
w=A.af(w,!0,x.Q)
v=w==null?null:w.r
if(v==null)v=0
w=u.f
if(w!==-1&&v!==w)u.jA()
u.f=v},
jA(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$jA=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
q=A.af(n,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.alv(q),$async$jA)
case 7:p=e
if(r.c!=null)r.p(new C.bb9(r,p))
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
return A.p($async$jA,v)},
vA(d,e){return this.anW(d,e)},
anW(d,e){var w=0,v=A.q(x.H),u=1,t=[],s=[],r=this,q,p,o,n,m,l,k
var $async$vA=A.m(function(f,g){if(f===1){t.push(g)
w=u}for(;;)switch(w){case 0:m=J.a7(d)
l=A.bU(m.h(d,"id"))
r.p(new C.bb7(r,l))
o=r.c
o.toString
o=A.af(o,!1,x.d).c
o.toString
q=o
u=3
w=e?6:8
break
case 6:w=9
return A.h(C.akW(q,l),$async$vA)
case 9:o=r.c
if(o!=null)A.b7(o,"Order #"+A.k(m.h(d,"order_id"))+" is yours. Find it in My Deliveries for your pickup code.",!1)
r.a.c.$0()
w=7
break
case 8:w=10
return A.h(C.ala(q,l),$async$vA)
case 10:case 7:s.push(5)
w=4
break
case 3:u=2
k=t.pop()
p=A.a2(k)
m=r.c
if(m!=null)A.b7(m,A.b9(p),!0)
s.push(5)
w=4
break
case 2:s=[1]
case 4:u=1
if(r.c!=null)r.p(new C.bb8(r))
w=11
return A.h(r.jA(),$async$vA)
case 11:w=s.pop()
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$vA,v)},
t(d){var w,v,u,t,s,r,q=this,p=null
if(J.d5(q.d))return B.aK
w=A.a([A.j("Requests for you",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.t:B.r,p,p,p,p,p,p,p,p,17,p,p,B.C,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),B.a6],x.p)
for(v=J.bt(q.d),u=q.gFI();v.B();){t=v.gO(v)
s=q.e
r=J.B(t,"id")
w.push(new C.abJ(t,s==null?r==null:s===r,new C.bba(q,t),u,p))}return new A.a0(D.vE,A.U(w,B.q,D.aq0,B.e,B.f,0,B.k),p)}}
C.abJ.prototype={
t(a1){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="total_amount",i="restaurant_address",h=A.c(a1).ax.a===B.c?B.t:B.r,g=A.c(a1).ax.a===B.c?B.v:B.u,f=Date.now(),e=l.c,d=J.a7(e),a0=A.cv(d.h(e,"seconds_left"))
a0=a0==null?k:B.h.bo(a0)
w=new A.cl(f,0,!1).pt(A.eL(0,0,a0==null?0:a0).a)
f=x.g.a(d.h(e,"items"))
if(f==null)f=B.bm
v=J.eo(f,new C.b2A(),x.N).b8(0,", ")
f=A.k(d.h(e,"id"))
a0=x.O
u=A.bS(a1)
t=A.a_(18)
s=A.aZ(B.m,B.n,1.5)
r=A.a([new A.di(0,B.bQ,B.m.N(0.18),B.Dr,16)],x.V)
q=d.h(e,"restaurant_name")
p=x.p
q=A.a([D.Yb,B.ac,A.ae(A.j(A.k(q==null?"A restaurant":q)+" asked you",k,k,k,k,A.t(k,k,h,k,k,k,k,k,k,k,k,15,k,k,B.C,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k),1)],p)
if(A.fK(d.h(e,j))){o=A.bI(A.bU(d.h(e,j)))
q.push(A.j(o,k,k,k,k,A.t(k,k,A.c(a1).ax.a===B.c?B.m:B.ap,k,k,k,k,k,k,k,k,k,k,k,B.C,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}q=A.V(q,B.i,k,B.e,B.f,0,k)
o=A.k(d.h(e,"order_id"))
n=v.length===0?"":" \xb7 "+v
n=A.a([q,B.aF,A.j("Order #"+o+n,k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],p)
if(d.h(e,i)!=null)n.push(A.j("Pick up: "+A.k(d.h(e,i)),k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))
n.push(B.O)
n.push(new E.A6(w,new C.b2B(l,g),k))
n.push(B.O)
q=A.k(d.h(e,"id"))
o=l.d
m=o?k:new C.b2C(l)
m=A.ae(A.wX(D.alz,new A.y("rider-offer-decline-"+q,a0),m,k),1)
e=A.k(d.h(e,"id"))
d=o?k:new C.b2D(l)
n.push(A.V(A.a([m,B.ae,A.ae(new A.cP("Accept delivery",d,o,k,new A.y("rider-offer-accept-"+e,a0)),2)],p),B.i,k,B.e,B.f,0,k))
return A.a3(k,A.U(n,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.Z(u,k,s,t,r,k,B.o),k,k,new A.y("rider-offer-card-"+f,a0),B.bW,B.bb,k,k,k)}}
C.aiI.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a2()}}
C.LV.prototype={
L(){return new C.Tt()}}
C.Tt.prototype={
V(){this.aa()
this.h5()},
h5(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$h5=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
q=A.af(n,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(E.Xm(q),$async$h5)
case 7:p=e
if(r.c!=null)r.p(new C.bbe(r,p))
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
return A.p($async$h5,v)},
zH(){var w=0,v=A.q(x.H),u=this,t
var $async$zH=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:t=u.c
t.toString
w=4
return A.h(A.e8(t,new E.qy(!0,null),x.P),$async$zH)
case 4:w=e!=null?2:3
break
case 2:w=5
return A.h(u.h5(),$async$zH)
case 5:case 3:return A.o(null,v)}})
return A.p($async$zH,v)},
t(a5){var w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,a0="status",a1="paid",a2="failed",a3="order_count",a4=this.d
if(a4==null)return B.aK
w=A.c(a5).ax.a===B.c?B.t:B.r
v=A.c(a5).ax.a===B.c?B.v:B.u
u=J.a7(a4)
t=J.f(u.h(a4,"payout_mode"),"automatic")
s=E.ajI(a4)
r=x.g.a(u.h(a4,"payouts"))
if(r==null)r=B.bm
q=J.eS(r,x.P)
r=A.bS(a5)
p=A.a_(18)
o=A.aZ(A.c(a5).ax.a===B.c?B.E:B.G,B.n,1)
n=A.j("Waiting to be paid",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
m=A.cv(u.h(a4,"owed"))
m=m==null?d:B.h.bo(m)
l=x.p
m=A.ae(A.U(A.a([n,A.j(A.bI(m==null?0:m),D.apv,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,22,d,d,B.du,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)
n=A.j("Paid to you",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
k=A.cv(u.h(a4,"paid_total"))
k=k==null?d:B.h.bo(k)
n=A.V(A.a([m,A.ae(A.U(A.a([n,A.j(A.bI(k==null?0:k),d,d,d,d,D.ahN,d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)],l),B.i,d,B.e,B.f,0,d)
u=A.cv(u.h(a4,"rider_share_percent"))
u=H.hL(u==null?100:u)
m=t?"after each delivery":"weekly"
m=A.a([n,B.ag,A.j("You earn "+u+" of each delivery fee, paid "+m+".",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,1.4,!0,d,d,d,d,d,d,d,d),d,d,d,d),B.O],l)
u=this.ganv()
if(s==null)m.push(A.bw(I.a_d(G.xd,D.aoK,D.amH,u),d,1/0))
else{n=A.a_(10)
k=A.ae(A.j("Paid to "+s,d,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,13.5,d,d,B.a1,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d),1)
m.push(A.dt(!1,n,!0,A.V(A.a([D.Y1,B.ac,k,A.j("Change",d,d,d,d,A.t(d,d,A.c(a5).ax.a===B.c?B.m:B.ap,d,d,d,d,d,d,d,d,13,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d,!0,d,d,d,d,d,d,d,d,d,d,d,u,d,d,d,d,d,d,d))}if(!q.gaf(q)){u=A.a([A.hS(A.c(a5).ax.a===B.c?B.E:B.G,24,d)],l)
for(n=A.hb(q,0,A.kS(3,"count",x.S),q.$ti.i("am.E")),k=n.$ti,n=new A.be(n,n.gC(0),k.i("be<aK.E>")),k=k.i("aK.E");n.B();){j=n.d
if(j==null)j=k.a(j)
i=J.a7(j)
if(J.f(i.h(j,a0),a1))h=B.cB
else h=J.f(i.h(j,a0),a2)?B.lN:B.hS
if(J.f(i.h(j,a0),a1))g=B.F
else g=J.f(i.h(j,a0),a2)?B.H:B.ab
g=A.ao(h,g,d,d,16)
h=A.bI(B.h.bo(A.bQ(i.h(j,"amount"))))
f=A.k(i.h(j,a3))
e=J.f(i.h(j,a3),1)?"y":"ies"
h=A.j(h+" \xb7 "+f+" deliver"+e,d,d,d,d,new A.x(!0,w,d,d,d,d,13,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)
if(J.f(i.h(j,a0),a1))j=H.bnx(i.h(j,"paid_at"))
else j=J.f(i.h(j,a0),a2)?"Failed":"Sending\u2026"
u.push(new A.a0(F.oQ,A.V(A.a([g,B.ac,new A.dr(1,B.b3,h,d),A.j(j,d,d,d,d,new A.x(!0,v,d,d,d,d,12,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d))}B.b.H(m,u)}return A.a3(d,A.U(m,B.q,d,B.e,B.f,0,B.k),B.j,d,d,new A.Z(r,d,o,p,d,d,B.o),d,d,D.aro,B.vp,B.dO,d,d,1/0)}}
C.LW.prototype={
L(){var w=$.a9()
return new C.Tz(new A.bs(B.a4,w),new A.bs(B.a4,w),new A.bs(B.a4,w),new A.bs(B.a4,w),new A.bs(B.a4,w))},
hf(d){return this.d.$1(d)}}
C.Tz.prototype={
V(){var w,v,u,t=this
t.aa()
w=t.a.c
v=J.a7(w)
u=v.h(w,"ghana_card")
t.d.sc0(0,A.k(u==null?"":u))
u=v.h(w,"licence_number")
t.e.sc0(0,A.k(u==null?"":u))
u=v.h(w,"plate")
t.f.sc0(0,A.k(u==null?"":u))
u=v.h(w,"emergency_name")
t.r.sc0(0,A.k(u==null?"":u))
u=v.h(w,"emergency_phone")
t.w.sc0(0,A.k(u==null?"":u))
v=v.h(w,"vehicle")
t.x=A.k(v==null?"motorbike":v)},
j(){var w,v,u,t=this
for(w=[t.d,t.e,t.f,t.r,t.w],v=0;v<5;++v){u=w[v]
u.R8$=$.a9()
u.p4$=0}t.a2()},
Bc(){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p,o
var $async$Bc=A.m(function(d,e){if(d===1){t.push(e)
w=u}for(;;)switch(w){case 0:u=3
q=s.c
q.toString
q=A.af(q,!1,x.d).c
q.toString
w=6
return A.h(C.Xs(q),$async$Bc)
case 6:r=e
s.a.hf(r)
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
return A.p($async$Bc,v)},
I_(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g,f
var $async$I_=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.x
g=h==="motorbike"||h==="car"
h=A.cH("^GHA-?\\d{9}-?\\d$",!1,!1)
n=q.d
m=B.d.a3(n.a.a)
if(!h.b.test(m)){h=q.c
h.toString
A.b7(h,"Enter your Ghana Card number, e.g. GHA-123456789-0.",!0)
w=1
break}if(g)h=B.d.a3(q.e.a.a).length<4||B.d.a3(q.f.a.a).length<4
else h=!1
if(h){h=q.c
h.toString
A.b7(h,"Add your licence number and number plate.",!0)
w=1
break}h=q.r
if(B.d.a3(h.a.a).length<2||B.d.a3(q.w.a.a).length<9){h=q.c
h.toString
A.b7(h,"Add someone we can call in an emergency.",!0)
w=1
break}q.p(new C.bbG(q))
t=4
m=q.c
m.toString
m=A.af(m,!1,x.d).c
m.toString
n=B.d.a3(n.a.a)
l=q.x
k=g?B.d.a3(q.e.a.a):null
j=g?B.d.a3(q.f.a.a):null
w=7
return A.h(C.amG(m,A.L(["ghana_card",n,"vehicle",l,"licence_number",k,"plate",j,"emergency_name",B.d.a3(h.a.a),"emergency_phone",B.d.a3(q.w.a.a)],x.N,x.z)),$async$I_)
case 7:p=e
q.a.hf(p)
h=q.c
if(h!=null)A.b7(h,"Sent! We'll let you know once you're approved.",!1)
r.push(6)
w=5
break
case 4:t=3
f=s.pop()
o=A.a2(f)
h=q.c
if(h!=null)A.b7(h,A.b9(o),!0)
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bbH(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$I_,v)},
t(d){var w,v,u,t,s,r,q,p,o,n,m,l,k,j=this,i=null,h=j.a.c,g=J.a7(h),f=A.k(g.h(h,"status")),e=x.g.a(g.h(h,"missing"))
if(e==null)e=B.bm
w=J.eo(e,new C.bbJ(),x.N).ij(0)
v=A.af(d,!0,x.d)
u=A.c(d).ax.a===B.c?B.t:B.r
t=A.c(d).ax.a===B.c?B.v:B.u
s=new C.bbM(d,t,u)
e=v.f
if(e==null)e=""
r=f==="pending"
e=A.IP(e,F.vG,"rider",r?"We're checking your details.":"Let's get you verified so you can start earning.")
q=x.p
p=A.a([],q)
if(r)p.push(new C.DM(B.fq,B.lO,"Thanks! Your details are with FindFood","We may call you to meet and see your Ghana Card"+(J.f(g.h(h,"vehicle"),"motorbike")||J.f(g.h(h,"vehicle"),"car")?" and licence":"")+". You'll get a notification as soon as you're approved.",D.asr))
else{r=A.a([],q)
o=f==="rejected"
if(o){g=g.h(h,"rejection_reason")
r.push(new C.DM(B.H,D.W1,"We couldn't approve you yet",A.k(g==null?"Please check your details.":g)+". Fix it below and send again.",D.asx))}else r.push(D.atE)
r.push(B.a3)
r.push(s.$4(1,"A clear photo of your face",!w.m(0,"photo"),D.TL))
r.push(s.$4(2,"Your phone number",!w.m(0,"phone"),A.c2(D.amO,D.apG,i,i,new C.bbK(j,d),i,i)))
r.push(s.$4(3,"Your ID and vehicle",!1,i))
r.push(B.aF)
r.push(A.cN(j.d,"Ghana Card number (GHA-123456789-0)",D.aq4,i,1,!1,i,D.V4,i,i,i))
r.push(B.O)
r.push(A.j("How do you deliver?",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a6)
g=A.a([],q)
for(n=D.D2.gha(D.D2),n=n.gal(n),m=x.O;n.B();){l=n.gO(n)
k=l.a
g.push(A.r1(i,i,new A.y("vehicle-"+k,m),A.j(l.b,i,i,i,i,i,i,i,i,i),i,new C.bbL(j,l),j.x===k,i,i,i,i))}r.push(A.fH(B.bo,g,B.bH,8,8))
g=j.x
if(g==="motorbike"||g==="car")B.b.H(r,A.a([B.O,A.cN(j.e,"Driver's licence number",D.aoQ,i,1,!1,i,B.wJ,i,i,i),B.ag,A.cN(j.f,"Number plate, e.g. GR 1234-24",D.apX,i,1,!1,i,B.lI,i,i,i)],q))
r.push(B.a3)
r.push(A.j("Emergency contact",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a6)
r.push(A.cN(j.r,"Their name",D.aqu,i,1,!1,i,B.dS,i,i,i))
r.push(B.ag)
r.push(A.cN(j.w,"Their phone number",D.as9,B.il,1,!1,i,B.lH,i,i,i))
r.push(B.a6)
r.push(A.j("Only FindFood admins see these details. We never share your Ghana Card number.",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,12,i,i,i,i,1.4,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a3)
g=o?"Send again":"Send for approval"
o=j.y
r.push(new A.cP(g,o||w.a!==0?i:j.gaF6(),o,i,D.aqZ))
if(w.a!==0)r.push(new A.a0(B.ja,A.j("Add your photo and phone number first (steps 1 and 2).",i,i,i,i,A.t(i,i,A.c(d).ax.a===B.c?B.m:B.ap,i,i,i,i,i,i,i,i,12.5,i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i),i))
B.b.H(p,r)}return A.ex(A.dE(A.a([e,new A.a0(B.lo,A.U(p,B.q,i,B.e,B.f,0,B.k),i)],q),i,i,D.RY,i,B.V,!1),B.m,j.gaEl())}}
C.DM.prototype={
t(d){var w,v,u=this,t=null,s=u.c,r=s.N(0.1),q=A.a_(14),p=A.aZ(s.N(0.35),B.n,1)
s=A.ao(u.d,s,t,t,22)
w=A.j(u.e,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.t:B.r,t,t,t,t,t,t,t,t,t,t,t,B.C,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)
v=x.p
return A.a3(t,A.V(A.a([s,B.ae,A.ae(A.U(A.a([w,B.h1,A.j(u.f,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.v:B.u,t,t,t,t,t,t,t,t,13,t,t,t,t,1.4,!0,t,t,t,t,t,t,t,t),t,t,t,t)],v),B.q,t,B.e,B.f,0,B.k),1)],v),B.q,t,B.e,B.f,0,t),B.j,t,t,new A.Z(r,t,p,q,t,t,B.o),t,t,t,t,B.bl,t,t,1/0)}}
var z=a.updateTypes(["ar<~>()","ty(@)","ar<~>({silent:M})","d(ty)","~(jR)"])
C.aEW.prototype={
$1(d){var w,v,u,t,s="completed_at"
x.P.a(d)
w=J.a7(d)
v=w.h(d,"order_id")
u=w.h(d,"restaurant_name")
w.h(d,"delivery_address")
t=w.h(d,"earning")
if(t==null)t=0
if(w.h(d,s)==null)w=null
else{w=A.iO(J.bH(w.h(d,s)))
w=w==null?null:w.hF()}return new C.ty(v,u,t,w)},
$S:z+1}
C.baT.prototype={
$1(d){var w=this.a
return w.p(new C.baS(w,d))},
$S:12}
C.baS.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.aOW.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aP1.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.aP2.prototype={
$0(){return this.a.f=!this.b},
$S:0}
C.aOV.prototype={
$0(){return this.a.r=C.btl(this.b)},
$S:0}
C.aP6.prototype={
$1(d){return this.a.HB()},
$S:30}
C.aP7.prototype={
$1(d){},
$S:14}
C.aOX.prototype={
$0(){var w=this.a
w.e=!0
w.x=""},
$S:0}
C.aOY.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.ba(v)},
$S:0}
C.aOZ.prototype={
$0(){return this.a.x=A.b9(this.b)},
$S:0}
C.aP_.prototype={
$0(){return this.a.e=!1},
$S:0}
C.aP0.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.ba(v)},
$S:0}
C.aOS.prototype={
$0(){return J.zg(this.a.d,new C.aOR(this.b))},
$S:0}
C.aOR.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aP4.prototype={
$1(d){var w=this.a
return w.p(new C.aP3(w,d))},
$S:46}
C.aP3.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aP5.prototype={
$2(d,e){var w=this.a
return w.ari(J.B(w.d,e))},
$S:94}
C.aOT.prototype={
$0(){return this.a.o9(this.b)},
$S:0}
C.aOU.prototype={
$0(){return this.a.FA(this.b)},
$S:0}
C.b21.prototype={
$0(){return this.a.ws(!0)},
$S:2}
C.b1O.prototype={
$0(){var w=this.a
w.e=!0
w.f=""},
$S:0}
C.b1P.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.b1Q.prototype={
$0(){return this.a.f=A.b9(this.b)},
$S:0}
C.b1R.prototype={
$0(){return this.a.e=!1},
$S:0}
C.b1Z.prototype={
$1(d){var w=null,v=A.j("Release order #"+this.a.a+"?",w,w,w,w,w,w,w,w,w)
return A.fO(A.a([A.c2(D.ams,w,w,w,new C.b1X(d),w,w),A.c2(D.amy,D.arf,w,w,new C.b1Y(d),w,w)],x.p),w,D.akD,!1,w,v)},
$S:17}
C.b1X.prototype={
$0(){A.b_(this.a,!1).aX(!1)
return null},
$S:0}
C.b1Y.prototype={
$0(){A.b_(this.a,!1).aX(!0)
return null},
$S:0}
C.b2_.prototype={
$0(){return J.zg(this.a.d,new C.b1W(this.b))},
$S:0}
C.b1W.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b1N.prototype={
$1(d){return this.afn(d)},
afn(d){var w=0,v=A.q(x.H),u,t=this,s,r,q
var $async$$1=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=t.c
w=3
return A.h(E.zs(t.b,"/orders/"+s.a+"/deliver","Could not complete this delivery.",d),$async$$1)
case 3:r=f
q=t.a
if(q.c==null){w=1
break}q.p(new C.b1M(q,s,r))
case 1:return A.o(u,v)}})
return A.p($async$$1,v)},
$S:58}
C.b1M.prototype={
$0(){var w=this.a,v=J.WV(w.d,new C.b1L(this.b))
if(v!==-1)J.eJ(w.d,v,this.c)},
$S:0}
C.b1L.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b20.prototype={
$2(d,e){var w=this.a
return w.aAP(J.B(w.d,e))},
$S:94}
C.b1S.prototype={
$0(){var w,v,u=this.a.c
u.toString
w=this.b
v=w.f
return A.FQ(u,w.a,A.a([D.Ol,new A.l3("restaurant",v==null?"Restaurant":v,"Collecting the order")],x.J))},
$S:0}
C.b1T.prototype={
$0(){return this.a.o9(this.b)},
$S:0}
C.b1U.prototype={
$0(){return this.a.Bg(this.b)},
$S:0}
C.b1V.prototype={
$0(){return this.a.FV(this.b)},
$S:0}
C.bb0.prototype={
$0(){var w=this.a
w.f=!0
w.e=null},
$S:0}
C.bb1.prototype={
$0(){return this.a.d=C.btl(this.b)},
$S:0}
C.bb2.prototype={
$0(){return this.a.e=A.b9(this.b)},
$S:0}
C.bb3.prototype={
$0(){return this.a.f=!1},
$S:0}
C.bbF.prototype={
$0(){return A.e8(this.a,new E.qy(!0,null),x.P)},
$S:0}
C.bcV.prototype={
$2(d,e){var w,v,u,t,s,r,q,p=null,o=this.a,n=o.a
if(n===D.k1)return B.aK
w=n===D.I4
v=w?B.F:B.ab
u=v.N(0.1)
t=A.a_(14)
s=A.aZ(v.N(0.35),B.n,1)
r=A.ao(w?B.pW:D.W3,v,p,p,20)
q=w?"The customer can see you on the map. Keep FindFood open while you deliver.":"Turn on location so the customer can see you coming."
r=A.a([r,B.ae,A.ae(A.j(q,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.t:B.r,p,p,p,p,p,p,p,p,13,p,p,B.a1,p,1.35,!0,p,p,p,p,p,p,p,p),p,p,p,p),1)],x.p)
if(!w)r.push(A.c2(D.amc,D.aqb,p,p,o.gaVa(),p,p))
return A.a3(p,A.V(r,B.i,p,B.e,B.f,0,p),B.j,p,p,new A.Z(u,p,s,t,p,p,B.o),p,p,D.aqy,D.vE,D.Sx,p,p,p)},
$S:47}
C.als.prototype={
$1(d){return A.BG(d)},
$S:206}
C.aF2.prototype={
$1(d){return this.a.fZ(0)},
$S:30}
C.aF1.prototype={
$1(d){return d.ch!=null&&d.r==="delivery"&&B.b.m(F.xG,d.c)},
$S:23}
C.aF_.prototype={
$1(d){var w=this.a
w.BB()
w.pS(D.mQ)},
$S:14}
C.aF0.prototype={
$1(d){var w=this.a,v=w.f
if(v!=null)w.Bn(v,!0)},
$S:30}
C.bb9.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bb7.prototype={
$0(){return this.a.e=this.b},
$S:0}
C.bb8.prototype={
$0(){return this.a.e=null},
$S:0}
C.bba.prototype={
$1(d){return this.a.vA(this.b,d)},
$S:6}
C.b2A.prototype={
$1(d){var w=J.a7(d)
return A.k(w.h(d,"quantity"))+"\xd7 "+A.k(w.h(d,"name"))},
$S:102}
C.b2B.prototype={
$2(d,e){var w,v,u,t=null,s=e.a
if(s===0)$.aj.aQ$.push(new C.b2z(this.a))
w=A.a_(4)
s=B.l.c_(s,1e6)
v=s>30?B.m:B.H
u=A.c(d).ax.a===B.c?B.E:B.G
return A.U(A.a([A.h3(w,E.bs1(u,v,5,s/180,t)),B.aI,A.j(E.bxc(e)+" left to answer",t,t,t,t,A.t(t,t,this.b,t,t,t,t,t,t,t,t,12,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k)},
$S:752}
C.b2z.prototype={
$1(d){return this.a.f.$0()},
$S:4}
C.b2C.prototype={
$0(){return this.a.e.$1(!1)},
$S:0}
C.b2D.prototype={
$0(){return this.a.e.$1(!0)},
$S:0}
C.bbe.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bbG.prototype={
$0(){return this.a.y=!0},
$S:0}
C.bbH.prototype={
$0(){return this.a.y=!1},
$S:0}
C.bbJ.prototype={
$1(d){return A.k(d)},
$S:102}
C.bbM.prototype={
$4(d,e,f,g){var w,v,u,t=this,s=null
if(f)w=B.F
else w=A.c(t.a).ax.a===B.c?B.au:B.at
if(f)v=B.F
else v=A.c(t.a).ax.a===B.c?B.E:B.G
v=A.aZ(v,B.n,1)
u=f?D.Xz:A.j(""+d,s,s,s,s,A.t(s,s,t.b,s,s,s,s,s,s,s,s,s,s,s,B.C,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s)
v=A.a3(B.a5,u,B.j,s,s,new A.Z(w,s,v,s,s,s,B.as),s,28,s,s,s,s,s,28)
w=f?B.J5:s
w=A.a([v,B.aB,A.ae(A.j(e,s,s,s,s,A.t(s,s,t.c,s,w,s,s,s,s,s,s,s,s,s,B.z,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s),1)],x.p)
if(!f&&g!=null)w.push(g)
return new A.a0(B.bW,A.V(w,B.i,s,B.e,B.f,0,s),s)},
$S:753}
C.bbK.prototype={
$0(){var w=0,v=A.q(x.H),u=this
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:w=2
return A.h(A.e8(u.b,B.tb,x.H),$async$$0)
case 2:w=3
return A.h(u.a.Bc(),$async$$0)
case 3:return A.o(null,v)}})
return A.p($async$$0,v)},
$S:2}
C.bbL.prototype={
$1(d){var w=this.a
return w.p(new C.bbI(w,this.b))},
$S:6}
C.bbI.prototype={
$0(){return this.a.x=this.b.a},
$S:0};(function installTearOffs(){var w=a._instance_0u,v=a.installInstanceTearOff,u=a._instance_1u
var t
w(t=C.Ox.prototype,"gaIg","Ix",0)
w(t,"gwr","j6",0)
v(C.Rq.prototype,"gwr",0,0,null,["$1$silent","$0"],["ws","j6"],2,0,0)
w(t=C.Tr.prototype,"gwr","j6",0)
u(t,"gaEb","aEc",3)
w(t=C.LS.prototype,"gaVa","Mg",0)
u(t,"gaAK","aAL",4)
w(C.Ts.prototype,"gFI","jA",0)
w(C.Tt.prototype,"ganv","zH",0)
w(t=C.Tz.prototype,"gaEl","Bc",0)
w(t,"gaF6","I_",0)})();(function inheritance(){var w=a.mixinHard,v=a.inheritMany,u=a.inherit
v(A.R,[C.ty,C.aEV])
v(A.im,[C.aEW,C.baT,C.aP6,C.aP7,C.aOR,C.aP4,C.b1Z,C.b1W,C.b1N,C.b1L,C.als,C.aF2,C.aF1,C.aF_,C.aF0,C.bba,C.b2A,C.b2z,C.bbJ,C.bbM,C.bbL])
v(A.N,[C.tx,C.Ow,C.Rp,C.Tq,C.LT,C.LV,C.LW])
v(A.O,[C.aeo,C.Ox,C.ai8,C.Tr,C.aiI,C.Tt,C.Tz])
v(A.n7,[C.baS,C.aOW,C.aP1,C.aP2,C.aOV,C.aOX,C.aOY,C.aOZ,C.aP_,C.aP0,C.aOS,C.aP3,C.aOT,C.aOU,C.b21,C.b1O,C.b1P,C.b1Q,C.b1R,C.b1X,C.b1Y,C.b2_,C.b1M,C.b1S,C.b1T,C.b1U,C.b1V,C.bb0,C.bb1,C.bb2,C.bb3,C.bbF,C.bb9,C.bb7,C.bb8,C.b2C,C.b2D,C.bbe,C.bbG,C.bbH,C.bbK,C.bbI])
v(A.oU,[C.aP5,C.b20,C.bcV,C.b2B])
u(C.Rq,C.ai8)
v(A.a6,[C.aes,C.afc,C.abJ,C.DM])
u(C.Mv,A.yu)
u(C.LS,A.b1)
u(C.Ts,C.aiI)
w(C.ai8,H.hA)
w(C.aiI,H.hA)})()
A.z1(b.typeUniverse,JSON.parse('{"Ow":{"N":[],"d":[],"e":[]},"Rp":{"N":[],"d":[],"e":[]},"Tq":{"N":[],"d":[],"e":[]},"tx":{"N":[],"d":[],"e":[]},"aeo":{"O":["tx"]},"Ox":{"O":["Ow"]},"Rq":{"O":["Rp"]},"Tr":{"O":["Tq"]},"aes":{"a6":[],"d":[],"e":[]},"afc":{"a6":[],"d":[],"e":[]},"LS":{"b1":[],"aA":[]},"LT":{"N":[],"d":[],"e":[]},"Ts":{"O":["LT"]},"abJ":{"a6":[],"d":[],"e":[]},"LV":{"N":[],"d":[],"e":[]},"Tt":{"O":["LV"]},"LW":{"N":[],"d":[],"e":[]},"Tz":{"O":["LW"]},"DM":{"a6":[],"d":[],"e":[]}}'))
var y={a:"https://findfooddelivery-backend.onrender.com/deliveries/offers/",d:"https://findfooddelivery-backend.onrender.com/riders/me/verification"}
var x=(function rtii(){var w=A.aG
return{d:w("l0"),f:w("rq"),V:w("D<di>"),J:w("D<l3>"),A:w("D<eY>"),s:w("D<r>"),p:w("D<d>"),D:w("X<aD<r,@>>"),l:w("X<eY>"),j:w("X<@>"),P:w("aD<r,@>"),W:w("eY"),L:w("ty"),N:w("r"),O:w("y<r>"),q:w("uq"),y:w("M"),i:w("W"),z:w("@"),S:w("A"),g:w("X<@>?"),Q:w("t_?"),H:w("~")}})();(function constants(){var w=a.makeConstList
D.KX=new I.zj("Rider",null)
D.Ol=new A.l3("customer","Customer","Directions and delivery updates")
D.RY=new A.a1(0,0,0,40)
D.S_=new A.a1(0,0,12,0)
D.Sx=new A.a1(14,12,10,12)
D.SE=new A.a1(15,0,0,0)
D.vz=new A.a1(16,12,16,12)
D.SJ=new A.a1(16,12,16,8)
D.vE=new A.a1(20,0,20,14)
D.TL=new I.An(44,null)
D.Vg=new A.a5(61734,"MaterialIcons",null,!1)
D.TR=new A.d6(D.Vg,"No deliveries right now","Stay online \u2014 new jobs appear as orders come in.",null,null,null)
D.TV=new A.d6(B.dQ,"You're offline","Go online to start seeing available deliveries.",null,null,null)
D.TW=new A.d6(B.dQ,"No deliveries yet","Accept a job from Available tab to get started.",null,null,null)
D.n7=new A.x(!0,null,null,"PlusJakartaSans",null,null,28,B.C,null,-0.8,null,null,1.15,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.akS=new A.al("Available jobs",null,D.n7,null,null,B.a2,null,null,null,null,null)
D.alo=new A.al("Tap a job to accept it",null,B.Ju,null,null,null,null,null,null,null,null)
D.a3l=w([D.akS,B.bu,D.alo],x.p)
D.Qh=new A.m_(B.V,B.e,B.f,B.q,null,B.k,null,0,D.a3l,null)
D.U4=new A.dr(1,B.b3,D.Qh,null)
D.V4=new A.a5(61112,"MaterialIcons",null,!1)
D.Vi=new A.a5(61838,"MaterialIcons",null,!1)
D.wv=new A.a5(61958,"MaterialIcons",null,!1)
D.W1=new A.a5(63510,"MaterialIcons",null,!1)
D.W3=new A.a5(63618,"MaterialIcons",null,!1)
D.WZ=new A.aS(F.jn,18,B.y,null,null)
D.Xs=new A.aS(B.fC,18,B.F,null,null)
D.Xz=new A.aS(B.fD,16,B.x,null,null)
D.XC=new A.aS(B.W_,16,B.F,null,null)
D.XO=new A.aS(B.co,16,B.m,null,null)
D.XY=new A.aS(B.lI,18,B.y,null,null)
D.Y1=new A.aS(B.fF,18,B.F,null,null)
D.Yb=new A.aS(B.co,20,B.aE,null,null)
D.Yd=new A.aS(F.x5,18,null,null,null)
D.V9=new A.a5(61495,"MaterialIcons",null,!1)
D.awd=new A.a5(63268,"MaterialIcons",null,!1)
D.UF=new A.hx(D.V9,"Available",0)
D.UG=new A.hx(B.dQ,"My Deliveries",0)
D.UA=new A.hx(B.jj,"Earnings",0)
D.a37=w([D.UF,D.UG,D.UA,B.wi],A.aG("D<hx>"))
D.a3B=new A.Bh(B.a3z,10,null)
D.a6o={motorbike:0,bicycle:1,car:2,on_foot:3}
D.D2=new A.bB(D.a6o,["Motorbike","Bicycle","Car","On foot"],A.aG("bB<r,r>"))
D.akX=new A.al("My deliveries",null,D.n7,null,null,null,null,null,null,null,null)
D.a7x=new A.a0(B.oV,D.akX,null)
D.Sg=new A.a1(0,60,0,0)
D.a7B=new A.a0(D.Sg,B.bY,null)
D.aaK=new C.LV(null)
D.XM=new A.aS(B.pX,18,B.y,null,null)
D.alN=new A.al("New delivery available!",null,G.Jc,null,null,null,null,null,null,null,null)
D.a2Y=w([D.XM,B.ac,D.alN],x.p)
D.aaQ=new A.j9(B.aJ,B.e,B.f,B.i,null,B.k,null,0,D.a2Y,null)
D.k1=new C.Mv(0,"idle")
D.I4=new C.Mv(1,"sharing")
D.mQ=new C.Mv(2,"blocked")
D.am9=new A.al("Could not open maps.",null,null,null,null,null,null,null,null,null,null)
D.IJ=new A.fV(D.am9,null,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.akv=new A.al("Delivery complete. Nice work!",null,B.b6,null,null,null,null,null,null,null,null)
D.ae2=new A.fV(D.akv,B.F,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.am4=new A.al("This order does not have a delivery destination.",null,null,null,null,null,null,null,null,null,null)
D.IK=new A.fV(D.am4,null,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.n6=new A.x(!0,null,null,"PlusJakartaSans",null,null,12,B.aw,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ahN=new A.x(!0,B.F,null,null,null,null,22,B.du,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.n8=new A.x(!0,null,null,"PlusJakartaSans",null,null,16,B.z,null,-0.1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.kh=new A.x(!0,null,null,"PlusJakartaSans",null,null,13,B.a1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.akp=new A.al("Earned today",null,D.kh,null,null,null,null,null,null,null,null)
D.akw=new A.al("Release this job",null,null,null,null,null,null,null,null,null,null)
D.akD=new A.al("It goes back to the available jobs for another rider. You can release up to 2 jobs a day, and never after collecting the food.",null,null,null,null,null,null,null,null,null,null)
D.akR=new A.al("Complete with customer's code",null,null,null,null,null,null,null,null,null,null)
D.alz=new A.al("Decline",null,null,null,null,null,null,null,null,null,null)
D.alH=new A.al("Earnings",null,D.n7,null,null,null,null,null,null,null,null)
D.alL=new A.al("Recent deliveries",null,B.Jn,null,null,null,null,null,null,null,null)
D.amc=new A.al("Turn on",null,null,null,null,null,null,null,null,null,null)
D.ame=new A.al("Profile",null,D.n7,null,null,null,null,null,null,null,null)
D.ams=new A.al("Keep job",null,null,null,null,null,null,null,null,null,null)
D.amy=new A.al("Release",null,B.kg,null,null,null,null,null,null,null,null)
D.amH=new A.al("Add your MoMo to get paid",null,null,null,null,null,null,null,null,null,null)
D.amJ=new A.al("Accept delivery",null,null,null,null,null,null,null,null,null,null)
D.amO=new A.al("Add",null,null,null,null,null,null,null,null,null,null)
D.aoK=new A.y("rider-add-payout",x.O)
D.aoQ=new A.y("verify-licence",x.O)
D.apv=new A.y("rider-owed",x.O)
D.apG=new A.y("verification-add-phone",x.O)
D.apX=new A.y("verify-plate",x.O)
D.aq0=new A.y("rider-offers",x.O)
D.aq4=new A.y("verify-card",x.O)
D.aqb=new A.y("rider-sharing-retry",x.O)
D.aqu=new A.y("verify-emergency-name",x.O)
D.aqy=new A.y("rider-sharing-banner",x.O)
D.aqZ=new A.y("verify-submit",x.O)
D.arf=new A.y("confirm-release",x.O)
D.aro=new A.y("rider-payout-card",x.O)
D.arI=new A.y("rider-online-toggle",x.O)
D.as9=new A.y("verify-emergency-phone",x.O)
D.asr=new A.y("verification-pending",x.O)
D.asx=new A.y("verification-rejected",x.O)
D.at1=new A.y("settings-rider-payout",x.O)
D.at3=new A.y("rider-today-earnings",x.O)
D.atA=new C.Ow(null)
D.Wm=new A.a5(983663,"MaterialIcons",null,!1)
D.atE=new C.DM(B.aE,D.Wm,"Riders are checked before their first job","It keeps customers and restaurants safe. It takes a few minutes to fill in.",null)
D.auY=new C.Rp(null)
D.avn=new C.Tq(null)
D.avp=new C.aes(null)
D.avz=new C.afc(null)})();(function lazyInitializers(){var w=a.lazyFinal
w($,"bRN","ajY",()=>new C.LS(D.k1,$.a9()))})()};
(a=>{a["SIBSUyvg4htyqDDu1UjhJCe/Jtk="]=a.current})($__dart_deferred_initializers__);