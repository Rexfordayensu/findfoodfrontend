((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,E,G,I,K,C={
btU(d){var w,v,u,t,s,r,q=J.a7(d)
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
r=A.ci(q.h(d,"average_rating"))
if(r==null)r=null
q=q.h(d,"recent_deliveries")
if(q==null)q=[]
q=J.en(x.j.a(q),new C.aF8(),x.L)
q=A.ah(q,q.$ti.i("aK.E"))
return new C.aF7(w,v,u,t,s,r,q)},
tB:function tB(d,e,f,g){var _=this
_.a=d
_.b=e
_.d=f
_.e=g},
aF7:function aF7(d,e,f,g,h,i,j){var _=this
_.c=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j},
aF8:function aF8(){},
bHK(){return new C.tA(null)},
tA:function tA(d){this.a=d},
aey:function aey(){this.d=0
this.c=this.a=null},
bbe:function bbe(d){this.a=d},
bbd:function bbd(d,e){this.a=d
this.b=e},
OA:function OA(d){this.a=d},
OB:function OB(d){var _=this
_.d=d
_.f=_.e=!0
_.w=_.r=null
_.x=""
_.y=null
_.z=0
_.c=_.a=null},
aPa:function aPa(d,e){this.a=d
this.b=e},
aPg:function aPg(d,e){this.a=d
this.b=e},
aPh:function aPh(d,e){this.a=d
this.b=e},
aP9:function aP9(d,e){this.a=d
this.b=e},
aPl:function aPl(d){this.a=d},
aPm:function aPm(){},
aPb:function aPb(d){this.a=d},
aPc:function aPc(d,e){this.a=d
this.b=e},
aPd:function aPd(d,e){this.a=d
this.b=e},
aPe:function aPe(d){this.a=d},
aPf:function aPf(d,e){this.a=d
this.b=e},
aP6:function aP6(d,e){this.a=d
this.b=e},
aP5:function aP5(d){this.a=d},
aPj:function aPj(d){this.a=d},
aPi:function aPi(d,e){this.a=d
this.b=e},
aPk:function aPk(d){this.a=d},
aP7:function aP7(d,e){this.a=d
this.b=e},
aP8:function aP8(d,e){this.a=d
this.b=e},
Rt:function Rt(d){this.a=d},
Ru:function Ru(d,e,f){var _=this
_.d=d
_.e=!0
_.f=""
_.dO$=e
_.i2$=f
_.c=_.a=null},
b2l:function b2l(d){this.a=d},
b27:function b27(d){this.a=d},
b28:function b28(d,e){this.a=d
this.b=e},
b29:function b29(d,e){this.a=d
this.b=e},
b2a:function b2a(d){this.a=d},
b2i:function b2i(d){this.a=d},
b2g:function b2g(d){this.a=d},
b2h:function b2h(d){this.a=d},
b2j:function b2j(d,e){this.a=d
this.b=e},
b2f:function b2f(d){this.a=d},
b26:function b26(d,e,f){this.a=d
this.b=e
this.c=f},
b25:function b25(d,e,f){this.a=d
this.b=e
this.c=f},
b24:function b24(d){this.a=d},
b2k:function b2k(d){this.a=d},
b2b:function b2b(d,e){this.a=d
this.b=e},
b2c:function b2c(d,e){this.a=d
this.b=e},
b2d:function b2d(d,e){this.a=d
this.b=e},
b2e:function b2e(d,e){this.a=d
this.b=e},
Tv:function Tv(d){this.a=d},
Tw:function Tw(){var _=this
_.e=_.d=null
_.f=!0
_.c=_.a=null},
bbm:function bbm(d){this.a=d},
bbn:function bbn(d,e){this.a=d
this.b=e},
bbo:function bbo(d,e){this.a=d
this.b=e},
bbp:function bbp(d){this.a=d},
aeC:function aeC(d){this.a=d},
bc0:function bc0(d){this.a=d},
afm:function afm(d){this.a=d},
bdq:function bdq(d){this.a=d},
aii:function aii(){},
Xm(d){var w=0,v=A.q(x.l),u,t,s
var $async$Xm=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bR("GET",A.aq("https://findfooddelivery-backend.onrender.com/deliveries/available",0,null),A.K(["Authorization","Bearer "+d],t,t)),$async$Xm)
case 3:s=f
t=s.b
if(t===200){t=J.en(A.f4(s),new C.alD(),x.W)
t=A.ah(t,t.$ti.i("aK.E"))
u=t
w=1
break}throw A.i(A.ag("Failed to load deliveries ("+t+")"))
case 1:return A.o(u,v)}})
return A.p($async$Xm,v)},
Xx(d){var w=0,v=A.q(x.P),u,t,s,r
var $async$Xx=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bR("GET",A.aq("https://findfooddelivery-backend.onrender.com/riders/me/analytics",0,null),A.K(["Authorization","Bearer "+d],t,t)),$async$Xx)
case 3:s=f
r=A.bf(s)
if(s.b===200){u=r
w=1
break}t=J.B(r,"detail")
throw A.i(A.ag(t==null?"Failed to load analytics":t))
case 1:return A.o(u,v)}})
return A.p($async$Xx,v)},
XG(d,e){var w=0,v=A.q(x.H),u,t
var $async$XG=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aE().bl("PUT",A.aq("https://findfooddelivery-backend.onrender.com/riders/me/online",0,null),A.K(["Content-Type","application/json","Authorization","Bearer "+d],u,u),B.T.bG(A.K(["online",e],u,x.y),null),null),$async$XG)
case 2:t=g
if(t.b!==200)throw A.i(A.ag(A.bp(t,"Could not change your status")))
return A.o(null,v)}})
return A.p($async$XG,v)},
alG(d){var w=0,v=A.q(x.D),u,t,s
var $async$alG=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bR("GET",A.aq("https://findfooddelivery-backend.onrender.com/deliveries/offers",0,null),A.K(["Authorization","Bearer "+d],t,t)),$async$alG)
case 3:s=f
if(s.b===200){u=A.dL(A.f4(s),!0,x.P)
w=1
break}throw A.i(A.ag(A.bp(s,"Could not load requests")))
case 1:return A.o(u,v)}})
return A.p($async$alG,v)},
al6(d,e){var w=0,v=A.q(x.W),u,t,s
var $async$al6=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bl("POST",A.aq(y.a+e+"/accept",0,null),A.K(["Authorization","Bearer "+d],t,t),null,null),$async$al6)
case 3:s=g
if(s.b===200){u=A.BH(A.bf(s))
w=1
break}throw A.i(A.ag(A.bp(s,"Could not accept the delivery")))
case 1:return A.o(u,v)}})
return A.p($async$al6,v)},
all(d,e){var w=0,v=A.q(x.H),u,t
var $async$all=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aE().bl("POST",A.aq(y.a+e+"/decline",0,null),A.K(["Authorization","Bearer "+d],u,u),null,null),$async$all)
case 2:t=g
if(t.b!==200)throw A.i(A.ag(A.bp(t,"Could not decline")))
return A.o(null,v)}})
return A.p($async$all,v)},
Xy(d){var w=0,v=A.q(x.P),u,t,s
var $async$Xy=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bR("GET",A.aq(y.d,0,null),A.K(["Authorization","Bearer "+d],t,t)),$async$Xy)
case 3:s=f
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bp(s,"Could not load your verification")))
case 1:return A.o(u,v)}})
return A.p($async$Xy,v)},
amT(d,e){var w=0,v=A.q(x.P),u,t,s
var $async$amT=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bl("PUT",A.aq(y.d,0,null),A.K(["Content-Type","application/json","Authorization","Bearer "+d],t,t),B.T.bG(e,null),null),$async$amT)
case 3:s=g
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bp(s,"Could not send your details")))
case 1:return A.o(u,v)}})
return A.p($async$amT,v)},
amZ(d,e,f,g){var w=0,v=A.q(x.y),u,t,s,r,q,p
var $async$amZ=A.m(function(h,i){if(h===1)return A.n(i,v)
for(;;)switch(w){case 0:s=$.aE()
r=A.aq("https://findfooddelivery-backend.onrender.com/riders/me/location",0,null)
q=x.N
p=A.K(["Authorization","Bearer "+d,"Content-Type","application/json"],q,q)
q=A.G(q,x.i)
q.n(0,"lat",f)
q.n(0,"lng",g)
if(e!=null)q.n(0,"heading",e)
w=3
return A.h(s.bl("PUT",r,p,B.T.bG(q,null),null),$async$amZ)
case 3:t=i
if(t.b===200){u=J.f(J.B(A.bf(t),"sharing"),!0)
w=1
break}throw A.i(A.ag(A.bp(t,"Could not share your location")))
case 1:return A.o(u,v)}})
return A.p($async$amZ,v)},
alD:function alD(){},
Mz:function Mz(d,e){this.a=d
this.b=e},
LW:function LW(d,e){var _=this
_.a=d
_.r=_.f=_.e=_.d=_.c=_.b=null
_.w=!1
_.p4$=0
_.R8$=e
_.rx$=_.RG$=0},
aFf:function aFf(d){this.a=d},
aFe:function aFe(){},
aFc:function aFc(d){this.a=d},
aFd:function aFd(d){this.a=d},
LX:function LX(d,e){this.c=d
this.a=e},
Tx:function Tx(d,e,f){var _=this
_.d=d
_.e=null
_.f=-1
_.dO$=e
_.i2$=f
_.c=_.a=null},
bbv:function bbv(d,e){this.a=d
this.b=e},
bbt:function bbt(d,e){this.a=d
this.b=e},
bbu:function bbu(d){this.a=d},
bbw:function bbw(d,e){this.a=d
this.b=e},
abS:function abS(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
b2U:function b2U(){},
b2V:function b2V(d,e){this.a=d
this.b=e},
b2T:function b2T(d){this.a=d},
b2W:function b2W(d){this.a=d},
b2X:function b2X(d){this.a=d},
aiS:function aiS(){},
LZ:function LZ(d){this.a=d},
Ty:function Ty(){this.c=this.a=this.d=null},
bbA:function bbA(d,e){this.a=d
this.b=e},
M_:function M_(d,e,f){this.c=d
this.d=e
this.a=f},
TE:function TE(d,e,f,g,h){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x="motorbike"
_.y=!1
_.c=_.a=null},
bc1:function bc1(d){this.a=d},
bc2:function bc2(d){this.a=d},
bc4:function bc4(){},
bc7:function bc7(d,e,f){this.a=d
this.b=e
this.c=f},
bc5:function bc5(d,e){this.a=d
this.b=e},
bc6:function bc6(d,e){this.a=d
this.b=e},
bc3:function bc3(d,e){this.a=d
this.b=e},
DO:function DO(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bw9(d,e,f,g){var w,v,u,t,s,r,q,p,o,n=null,m=e.length,l="",k=n
if(m!==0){v=0
for(;;){if(!(v<m)){w=0
break}if(e.charCodeAt(v)===64){l=B.d.ae(e,0,v)
w=v+1
break}++v}if(w<m&&e.charCodeAt(w)===91){for(u=w,t=-1;u<m;++u){s=e.charCodeAt(u)
if(s===37&&t<0){r=B.d.eg(e,"25",u+1)?u+2:u
t=u
u=r}else if(s===93)break}if(u===m)throw A.i(A.d1("Invalid IPv6 host entry.",e,w))
q=t<0?u:t
A.buS(e,w+1,q);++u
if(u!==m&&e.charCodeAt(u)!==58)throw A.i(A.d1("Invalid end of authority",e,u))}else u=w
for(;u<m;++u)if(e.charCodeAt(u)===58){p=B.d.cb(e,u+1)
k=p.length!==0?A.h_(p,n):n
break}o=B.d.ae(e,w,u)}else o=n
return A.iJ(n,o,n,A.a(f.split("/"),x.s),k,g,d,l)}},D,H,F
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
C.tB.prototype={}
C.aF7.prototype={}
C.tA.prototype={
L(){return new C.aey()}}
C.aey.prototype={
U(){var w,v
this.a9()
w=this.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)$.ak8().NA(0,v)},
j(){var w=$.ak8(),v=w.c
if(v!=null)v.ak(0)
w.b=w.c=null
w.BG()
w.pU(D.k3)
this.a2()},
t(d){var w=null,v=this.d
return A.d3(w,w,new A.rr([D.aug,D.avE,D.aw3,D.aw5][v],w),A.auc(0,w,w,v,D.a3l,w,new C.bbe(this)),w,!0,w,w)}}
C.OA.prototype={
L(){return new C.OB(A.a([],x.A))}}
C.OB.prototype={
He(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$He=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=r.c
m.toString
q=A.af(m,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.Xy(q),$async$He)
case 7:p=e
if(r.c==null){w=1
break}m=r.w
o=J.f(m==null?null:J.B(m,"can_work"),!1)
r.p(new C.aPa(r,p))
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
return A.p($async$He,v)},
IB(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$IB=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=!r.f
r.p(new C.aPg(r,m))
o=r.c
o.toString
q=A.af(o,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.XG(q,m),$async$IB)
case 7:t=2
w=6
break
case 4:t=3
l=s.pop()
p=A.a3(l)
if(r.c==null){w=1
break}r.p(new C.aPh(r,m))
r.c.V(x.q).f.bJ(A.cW(null,null,null,null,null,B.A,null,A.j(A.b9(p),null,null,null,null,null,null,null,null,null),null,B.ag,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$IB,v)},
Hd(d){return this.aAl(d)},
aAl(d){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p
var $async$Hd=A.m(function(e,f){if(e===1){t.push(f)
w=u}for(;;)switch(w){case 0:u=3
w=6
return A.h(C.Xx(d),$async$Hd)
case 6:r=f
if(s.c!=null)s.p(new C.aP9(s,r))
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
return A.p($async$Hd,v)},
ob(d){return this.aCz(d)},
aCz(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$ob=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a4(r).length===0){t.c.V(x.q).f.bJ(D.IR)
w=1
break}w=3
return A.h(A.uK(C.bw9("https","www.google.com","/maps/dir/",A.K(["api","1","destination",r],x.N,x.z)).giA(),B.m2,null),$async$ob)
case 3:if(!f&&t.c!=null)t.c.V(x.q).f.bJ(D.IQ)
case 1:return A.o(u,v)}})
return A.p($async$ob,v)},
U(){var w,v,u=this
u.a9()
u.j6()
u.He()
u.y=A.ib(B.oP,new C.aPl(u))
w=u.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)C.XG(v,!0).dz(new C.aPm())},
j(){var w=this.y
if(w!=null)w.ak(0)
this.a2()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d)
if(p.c==null){w=1
break}q.p(new C.aPb(q))
l=p.c
l.toString
q.Hd(l)
t=4
l=p.c
l.toString
w=7
return A.h(C.Xm(l),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.aPc(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a3(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.aPd(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.aPe(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
HE(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$HE=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(!r.f){w=1
break}o=r.c
o.toString
q=A.af(o,!1,x.d)
if(q.c==null){w=1
break}t=4
o=q.c
o.toString
w=7
return A.h(C.Xm(o),$async$HE)
case 7:p=e
if(r.c==null){w=1
break}if(J.ba(p)>r.z)r.c.V(x.q).f.bJ(A.cW(null,null,null,B.m,B.di,B.A,null,D.ab5,null,B.ag,null,null,null,B.b7,null,null,null,new A.bx(A.W(12),B.I),null,null))
r.p(new C.aPf(r,p))
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
return A.p($async$HE,v)},
FF(d){return this.anq(d)},
anq(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l,k,j
var $async$FF=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=r.c
k.toString
q=A.af(k,!1,x.d)
t=4
k=q.c
k.toString
n=""+d.a
w=7
return A.h(E.zs(k,"/deliveries/"+n+"/accept","Could not accept this delivery.",null),$async$FF)
case 7:p=f
$.ak8().fZ(0)
if(r.c==null){w=1
break}r.p(new C.aP6(r,d))
k=r.c.V(x.q).f
m=p.ok
if(m==null)m="in My deliveries"
k.bJ(A.cW(null,null,null,B.H,null,B.A,null,A.j("Delivery #"+n+" accepted. Your pickup code is "+m+" \u2014 give it to the restaurant when you collect.",null,null,null,null,B.b3,null,null,null,null),null,B.ag,null,null,null,null,null,null,null,null,null,null))
t=2
w=6
break
case 4:t=3
j=s.pop()
o=A.a3(j)
k=r.c
if(k==null){w=1
break}k.V(x.q).f.bJ(A.cW(null,null,null,B.G,null,B.A,null,A.j(A.b9(o),null,null,null,null,B.b3,null,null,null,null),null,B.ag,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$FF,v)},
t(d){var w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.w
if(l!=null&&J.f(J.B(l,"can_work"),!1)){if(d.df(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b0:B.aQ
return A.d3(m,w,A.dS(!0,new C.M_(l,new C.aPj(n),m),B.X,!0),m,m,!1,m,m)}if(d.df(x.f)!=null)w=B.D
else w=A.c(d).ax.a===B.c?B.b0:B.aQ
v=A.af(d,!0,x.d).f
if(v==null)v=""
if(n.f)if(J.d6(n.d))u=m
else{u=J.ba(n.d)
t=J.ba(n.d)===1?"":"s"
t=""+u+" job"+t+" near you right now."
u=t}else u="You're offline. Go online to get delivery jobs."
u=A.IU(v,G.vO,"rider",u)
if(n.f)v=B.H.N(0.12)
else v=A.c(d).ax.a===B.c?B.ar:B.aq
t=A.W(20)
if(n.f)s=B.H.N(0.5)
else s=A.c(d).ax.a===B.c?B.E:B.F
s=A.aZ(s,B.n,1)
if(n.f)r=B.H
else r=A.c(d).ax.a===B.c?B.R:B.Q
r=A.ea(m,m,m,B.Z,new A.X(r,m,m,m,m,m,B.av),B.cA,m,8,m,m,8)
q=n.f
p=q?"Online":"Offline"
if(q)q=B.H
else q=A.c(d).ax.a===B.c?B.R:B.Q
o=x.p
t=A.V(A.a([D.Uc,B.aC,A.ce(m,A.ea(m,A.V(A.a([r,B.bJ,A.j(p,m,m,m,m,A.t(m,m,q,m,m,m,m,m,m,m,m,13,m,m,B.a1,m,m,!0,m,m,m,m,m,m,m,m),m,m,m,m)],o),B.i,m,B.e,B.f,0,m),m,B.Z,new A.X(v,m,s,t,m,m,B.o),B.cA,m,m,m,F.lp,m),B.L,!1,D.ask,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,n.gaIs(),m,m,m,m,m,m,!1,B.aa),B.ac,F.qS],o),B.i,m,B.bM,B.f,0,m)
s=n.gwu()
v=n.S4(F.jp,""+J.ba(n.d),"Available")
q=n.r
r=q==null?m:q.f
r=n.S4(F.jn,""+(r==null?0:r),"Completed today")
q=n.r
q=q==null?m:q.e
v=A.bv(A.dE(A.a([v,r,n.S4(B.hR,A.bz(q==null?0:q),"Earned today")],o),m,m,B.lq,m,B.aK,!1),80,m)
if(!n.f)r=D.U2
else if(n.e)r=B.bW
else{r=n.x
if(r.length!==0)r=new A.d9(B.b9,"Connection failed",r,"Retry",s,m)
else r=J.d6(n.d)?D.TZ:A.ex(A.rQ(m,new C.aPk(n),J.ba(n.d),G.vQ),B.m,s)}return A.d3(m,w,A.dS(!0,A.U(A.a([u,new A.a0(G.vR,t,m),B.a2,new C.LX(s,m),v,B.a3,A.ad(r,1)],o),B.q,m,B.e,B.f,0,B.k),B.X,!0),m,m,!1,m,m)},
S4(d,e,f){var w,v,u,t,s,r=null,q=this.c
q.toString
q=A.bS(q)
w=A.W(14)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.F,B.n,1)
t=A.ao(d,B.m,r,r,20)
s=this.c
s.toString
v=x.p
return A.a2(r,A.V(A.a([t,B.ac,A.U(A.a([A.j(e,r,r,r,r,A.t(r,r,A.c(s).ax.a===B.c?B.v:B.u,r,r,r,r,r,r,r,r,18,r,r,B.B,r,r,!0,r,r,r,r,r,r,r,r),r,r,r,r),A.j(f,r,r,r,r,D.n9,r,r,r,r)],v),B.q,r,B.aU,B.f,0,B.k)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(q,r,u,w,r,r,B.o),r,r,r,D.S8,D.vI,r,r,r)},
art(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j=l.c
j.toString
j=A.bS(j)
w=A.W(16)
v=A.aZ(B.m.N(0.25),B.n,1)
u=""+d.a
t=x.p
s=A.V(A.a([A.j("Order #"+u,k,k,k,k,D.nb,k,k,k,k),A.j(A.bz(d.b),k,k,k,k,D.nb.bk(B.m),k,k,k,k)],t),B.i,k,B.bM,B.f,0,k)
r=A.a2(k,D.Y0,B.j,k,k,new A.X(B.m.N(0.12),k,k,k,k,k,B.av),k,32,k,k,k,k,k,32)
q=l.c
q.toString
p=A.j("Pickup",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.ax,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
o=d.f
q=o==null?"Restaurant":o
o=l.c
o.toString
r=A.V(A.a([r,B.aC,A.ad(A.U(A.a([p,A.j(q,k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,14,k,k,B.ax,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t),B.i,k,B.e,B.f,0,k)
q=l.c
q.toString
p=A.a2(k,k,B.j,A.c(q).ax.a===B.c?B.E:B.F,k,k,k,20,k,k,k,k,k,2)
o=A.a2(k,D.XO,B.j,k,k,new A.X(B.H.N(0.12),k,k,k,k,k,B.av),k,32,k,k,k,k,k,32)
n=l.c
n.toString
q=A.j("Dropoff",k,k,k,k,A.t(k,k,A.c(n).ax.a===B.c?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.ax,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
if(d.gDy())n="Pinned location"
else{n=d.z
n.toString
n=B.d.a4(n)}m=l.c
m.toString
q=A.a([o,B.aC,A.ad(A.U(A.a([q,A.j(n,k,2,B.a4,k,A.t(k,k,A.c(m).ax.a===B.c?B.v:B.u,k,k,k,k,k,k,k,k,14,k,k,B.ax,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gac8())B.b.H(q,A.a([B.ad,new A.qQ(D.wF,"Directions","Directions to the drop-off",new C.aP7(l,d),new A.y("available-directions-"+u,x.O))],t))
u=A.a([new A.a0(B.b8,A.U(A.a([s,B.az,r,new A.a0(D.SN,p,k),A.V(q,B.i,k,B.e,B.f,0,k)],t),B.q,k,B.e,B.f,0,B.k),k)],t)
if(d.cy.length!==0){s=l.c
s.toString
B.b.H(u,A.a([A.hS(A.c(s).ax.a===B.c?B.E:B.F,1,k),new A.a0(D.SS,new E.wZ(d,!0,k),k)],t))}t=l.c
t.toString
u.push(A.hS(A.c(t).ax.a===B.c?B.E:B.F,1,k))
u.push(new A.a0(B.b7,A.bv(A.ZZ(D.X9,k,D.an8,new C.aP8(l,d)),44,1/0),k))
return A.a2(k,A.U(u,B.i,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(j,k,v,w,k,k,B.o),k,k,k,B.fv,k,k,k,k)}}
C.Rt.prototype={
L(){return new C.Ru(A.a([],x.A),null,!1)}}
C.Ru.prototype={
ob(d){return this.aCA(d)},
aCA(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$ob=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a4(r).length===0){t.c.V(x.q).f.bJ(D.IR)
w=1
break}w=3
return A.h(A.uK(C.bw9("https","www.google.com","/maps/dir/",A.K(["api","1","destination",r],x.N,x.z)).giA(),B.m2,null),$async$ob)
case 3:if(!f&&t.c!=null)t.c.V(x.q).f.bJ(D.IQ)
case 1:return A.o(u,v)}})
return A.p($async$ob,v)},
U(){var w=this
w.a9()
w.j6()
w.j_(new C.b2l(w))},
wv(d){return this.aA8(d)},
j6(){return this.wv(!1)},
aA8(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j
var $async$wv=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=q.c
k.toString
p=A.af(k,!1,x.d)
if(p.c==null){w=1
break}k=!d
if(k)q.p(new C.b27(q))
t=4
m=p.c
m.toString
w=7
return A.h(A.lZ(m),$async$wv)
case 7:o=f
if(q.c==null){r=[1]
w=5
break}q.p(new C.b28(q,o))
r.push(6)
w=5
break
case 4:t=3
j=s.pop()
n=A.a3(j)
if(q.c==null||d){r=[1]
w=5
break}q.p(new C.b29(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null&&k)q.p(new C.b2a(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$wv,v)},
Bj(d){return this.aEF(d)},
aEF(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$Bj=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
w=3
return A.h(A.fd(null,null,!0,null,new C.b2i(d),n,null,!0,x.y),$async$Bj)
case 3:if(f!==!0||r.c==null){w=1
break}t=5
n=r.c
n.toString
n=A.af(n,!1,x.d).c
n.toString
p=""+d.a
w=8
return A.h(E.zs(n,"/deliveries/"+p+"/release","Could not release this delivery.",null),$async$Bj)
case 8:if(r.c==null){w=1
break}r.p(new C.b2j(r,d))
n=r.c.V(x.q).f
n.KL()
n.bJ(A.cW(null,null,null,null,null,B.A,null,A.j("Order #"+p+" released to other riders.",null,null,null,null,null,null,null,null,null),null,B.ag,null,null,null,null,null,null,null,null,null,null))
t=2
w=7
break
case 5:t=4
m=s.pop()
q=A.a3(m)
n=r.c
if(n==null){w=1
break}n=n.V(x.q).f
n.KL()
n.bJ(A.cW(null,null,null,B.G,null,B.A,null,A.j(A.b9(q),null,null,null,null,B.b3,null,null,null,null),null,B.ag,null,null,null,null,null,null,null,null,null,null))
w=7
break
case 4:w=2
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Bj,v)},
G_(d){return this.aqk(d)},
aqk(d){var w=0,v=A.q(x.H),u=this,t,s
var $async$G_=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=u.c
s.toString
s=A.af(s,!1,x.d).c
s.toString
t=u.c
t.toString
w=2
return A.h(E.ajU(t,"Complete delivery",null,"Ask the customer for the 4-digit delivery code shown in their FindFood app. Hand over the food once the code is accepted.",new C.b26(u,s,d),"Enter the customer's code"),$async$G_)
case 2:if(f&&u.c!=null)u.c.V(x.q).f.bJ(D.ael)
return A.o(null,v)}})
return A.p($async$G_,v)},
t(d){var w,v=this,u=null
if(v.e)w=B.bW
else{w=v.f
if(w.length!==0)w=new A.d9(B.b9,"Failed to load",w,"Retry",v.gwu(),u)
else w=J.d6(v.d)?D.U3:A.ex(A.rQ(u,new C.b2k(v),J.ba(v.d),G.vM),B.m,v.gwu())}return A.d3(u,u,A.dS(!0,A.U(A.a([D.a7M,D.awf,A.ad(w,1)],x.p),B.q,u,B.e,B.f,0,B.k),B.X,!0),u,u,!1,u,u)},
aB_(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="the restaurant",i=d.c,h=i==="out_for_delivery",g=l.c
g.toString
g=A.bS(g)
w=A.W(16)
if(h)v=B.m.N(0.4)
else{v=l.c
v.toString
v=A.c(v).ax.a===B.c?B.E:B.F}v=A.aZ(v,B.n,1)
u=""+d.a
t=x.p
s=A.a([A.ad(A.j("Order #"+u,k,k,k,k,D.nb,k,k,k,k),1)],t)
if(i!=="cancelled"){r=d.f
if(r==null)r=j
B.b.H(s,A.a([E.bqt(new A.y("rider-chat-"+u,x.O),new C.b2b(l,d),"the customer or "+r),B.ad],t))}s.push(new A.CY(i,k))
s=A.a([A.V(s,B.i,k,B.e,B.f,0,k),B.aG,A.j(A.bz(d.b),k,k,k,k,D.kj.bk(B.m),k,k,k,k)],t)
r=d.z
if(r!=null||d.Q!=null){if(d.gDy())r="Pinned location"
else{r.toString
r=B.d.a4(r)}r=A.a([A.j(r,k,2,B.a4,k,D.kj,k,k,k,k)],t)
if(d.gDy()){q=l.c
q.toString
r.push(A.j("Shared from the customer's phone",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,12,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}r=A.a([D.XD,B.ad,A.ad(A.U(r,B.q,k,B.e,B.f,0,B.k),1)],t)
if(d.gac8())B.b.H(r,A.a([B.ad,new A.qQ(D.wF,"Directions","Directions to the drop-off",new C.b2c(l,d),new A.y("rider-directions-"+u,x.O))],t))
B.b.H(s,A.a([B.N,A.V(r,B.i,k,B.e,B.f,0,k)],t))}if(d.ch!=null)r=i==="pending"||i==="preparing"||i==="ready"
else r=!1
if(r&&d.ok!=null){r=x.O
q=d.ok
q.toString
p=d.f
if(p==null)p=j
i=i==="ready"?"The food is ready.":"The kitchen is still preparing it."
o=l.c
o.toString
n=A.j("In the bag",k,k,k,k,A.t(k,k,A.c(o).ax.a===B.c?B.t:B.r,k,k,k,k,k,k,k,k,13,k,k,B.a1,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
m=l.c
m.toString
o=A.c(m).ax.a===B.c?B.v:B.u
m=l.c
m.toString
m=A.c(m).ax.a===B.c?B.E:B.F
B.b.H(s,A.a([B.az,new A.IW("Pickup code",q,"Check the bag is labelled #"+u+" and has everything below, then give this code to "+p+". "+i,B.dd,new A.y("rider-pickup-code-"+u,r)),B.N,n,B.aG,new E.wZ(d,!1,k),B.a2,A.bv(A.lr(D.Yq,new A.y("rider-release-"+u,r),D.akT,new C.b2d(l,d),A.ml(k,k,k,k,k,k,k,k,k,o,k,k,k,k,new A.bx(A.W(12),B.I),new A.av(m,1,B.n,-1),k,k,B.Jp,k)),46,1/0)],t))}if(h)B.b.H(s,A.a([B.az,A.bv(A.ZZ(D.Ya,new A.y("rider-complete-"+u,x.O),D.ald,new C.b2e(l,d)),46,1/0)],t))
return A.a2(k,A.U(s,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(g,k,v,w,k,k,B.o),k,k,k,B.fv,B.b8,k,k,k)}}
C.Tv.prototype={
L(){return new C.Tw()}}
C.Tw.prototype={
U(){this.a9()
this.j6()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d).c
if(p==null){w=1
break}q.p(new C.bbm(q))
t=4
w=7
return A.h(C.Xx(p),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.bbn(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a3(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.bbo(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bbp(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
t(d){var w,v,u,t,s,r,q=this,p=null,o=q.d,n=q.gwu(),m=x.p,l=A.a([D.am5,B.b2,D.ab_],m)
if(q.f&&o==null)l.push(D.a7Q)
else{w=q.e
if(w!=null&&o==null)l.push(A.U(A.a([A.j(w,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.t:B.r,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),A.c2(B.e4,p,p,p,n,p,p)],m),B.i,p,B.e,B.f,0,B.k))
else if(o!=null){w=A.W(16)
v=A.aZ(B.m.N(0.3),B.n,1)
u=A.bz(o.e)
u=A.j(u,D.atK,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.m:B.ao,p,p,p,p,p,p,p,p,36,p,p,B.B,p,p,!0,p,-1,p,p,p,p,p,p),p,p,p,p)
t=A.ao(D.Vt,A.c(d).ax.a===B.c?B.t:B.r,p,p,14)
s=o.f
r=s===1?"y":"ies"
w=A.a2(p,A.U(A.a([D.akM,B.aG,u,B.ae,A.V(A.a([t,B.bJ,A.j(""+s+" deliver"+r+" completed today",p,p,p,p,D.n9.bk(A.c(d).ax.a===B.c?B.t:B.r),p,p,p,p)],m),B.i,p,B.e,B.f,0,p)],m),B.q,p,B.e,B.f,0,B.k),B.j,p,p,new A.X(B.hA,p,v,w,p,p,B.o),p,p,p,p,B.d9,p,p,1/0)
v=A.V(A.a([q.I1("This week",A.bz(o.r)),B.dD,q.I1("This month",A.bz(o.w))],m),B.i,p,B.e,B.f,0,p)
u=q.I1("All time",A.bz(o.c))
t=o.x
m=A.a([w,B.az,v,B.az,A.V(A.a([u,B.dD,q.I1("Rating",t==null?"No ratings yet":"\u2605 "+B.h.ai(t,1))],m),B.i,p,B.e,B.f,0,p),B.aJ,D.am9,B.az],m)
w=o.y
if(w.length===0)m.push(A.j("Completed deliveries will appear here.",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.R:B.Q,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p))
else B.b.H(m,new A.ax(w,q.gaEm(),A.an(w).i("ax<1,d>")))
B.b.H(l,m)}}return A.d3(p,p,A.dS(!0,A.ex(A.dE(l,p,p,B.aw,p,B.V,!1),B.m,n),B.X,!0),p,p,!1,p,p)},
I1(d,e){var w,v,u,t=null,s=this.c
s.toString
s=A.bS(s)
w=A.W(14)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.F,B.n,1)
return A.ad(A.a2(t,A.U(A.a([A.j(d,t,t,t,t,D.n9,t,t,t,t),B.aF,A.j(e,t,t,t,t,D.nb,t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k),B.j,t,t,new A.X(s,t,u,w,t,t,B.o),t,t,t,t,B.b8,t,t,t),1)},
aEn(d){var w,v,u,t,s,r=null,q=d.e,p=A.a([],x.s),o=d.b
if(o!=null)p.push(o)
if(q!=null)p.push(""+A.ch(q)+"/"+A.bF(q)+" "+B.d.dd(B.l.k(A.kH(q)),2,"0")+":"+B.d.dd(B.l.k(A.lt(q)),2,"0"))
w=B.b.b9(p," \xb7 ")
p=this.c
p.toString
p=A.bS(p)
o=A.W(12)
v=this.c
v.toString
u=A.aZ(A.c(v).ax.a===B.c?B.E:B.F,B.n,1)
t=A.j("Order #"+d.a,r,r,r,r,D.kj,r,r,r,r)
s=this.c
s.toString
v=x.p
return A.a2(r,A.V(A.a([A.ad(A.U(A.a([t,A.j(w,r,r,r,r,D.n9.bk(A.c(s).ax.a===B.c?B.R:B.Q),r,r,r,r)],v),B.q,r,B.e,B.f,0,B.k),1),A.j(A.bz(d.d),r,r,r,r,D.kj.TV(B.m,B.z),r,r,r,r)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(p,r,u,o,r,r,B.o),r,r,r,B.bY,D.vI,r,r,r)}}
C.aeC.prototype={
t(d){var w=null,v=x.p
return A.d3(w,w,A.dS(!0,A.dE(A.a([D.amD,B.aJ,D.L4,B.dE,new A.uU("rider",A.a([new A.jc(K.pP,"Payout account","Where your delivery pay is sent",new C.bc0(d),w,D.atI)],v),w),B.aJ,K.rp],v),w,w,B.aw,w,B.V,!1),B.X,!0),w,w,!1,w,w)}}
C.afm.prototype={
t(d){var w=$.ak8()
return new A.mf(new C.bdq(w),null,w,null)}}
C.aii.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a2()}}
C.Mz.prototype={
K(){return"SharingState."+this.b}}
C.LW.prototype={
NA(d,e){var w,v=this
v.b=e
w=v.c
if(w!=null)w.ak(0)
v.c=A.ib(B.vq,new C.aFf(v))
v.fZ(0)},
fZ(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$fZ=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.b
if(n==null){w=1
break}t=4
w=7
return A.h(A.lZ(n),$async$fZ)
case 7:q=f
p=J.bBK(q,new C.aFe())
w=p?8:10
break
case 8:w=11
return A.h(r.wH(),$async$fZ)
case 11:w=9
break
case 10:r.BG()
r.pU(D.k3)
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
Mk(){var w=0,v=A.q(x.H),u=this
var $async$Mk=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:u.BG()
w=2
return A.h(u.fZ(0),$async$Mk)
case 2:return A.o(null,v)}})
return A.p($async$Mk,v)},
wH(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n
var $async$wH=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(r.e!=null){w=1
break}t=4
w=7
return A.h($.n_().y3(),$async$wH)
case 7:if(!e){p=r.pU(D.mT)
u=p
w=1
break}w=8
return A.h($.n_().n9(),$async$wH)
case 8:q=e
w=q===B.ev?9:10
break
case 9:w=11
return A.h($.n_().nB(0),$async$wH)
case 11:q=e
case 10:if(q===B.ev||q===B.hZ){p=r.pU(D.mT)
u=p
w=1
break}r.e=$.n_().XD(D.a3P).aRY(r.gaAV(),new C.aFc(r))
p=r.d
if(p!=null)p.ak(0)
r.d=A.ib(B.oO,new C.aFd(r))
r.pU(D.Ib)
t=2
w=6
break
case 4:t=3
n=s.pop()
r.pU(D.mT)
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$wH,v)},
aAW(d){this.f=d
this.aFf(d)},
Bq(d,e){return this.aGh(d,e)},
aFf(d){return this.Bq(d,!1)},
aGh(d,e){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$Bq=A.m(function(f,g){if(f===1){s.push(g)
w=t}for(;;)switch(w){case 0:l=q.b
if(l==null||q.w){w=1
break}o=new A.cm(Date.now(),0,!1)
if(!e){n=q.r
n=n!=null&&o.e5(n).a<6e6}else n=!1
if(n){w=1
break}q.w=!0
q.r=o
t=4
n=d.r
n=n>=0&&n<=360?n:null
w=7
return A.h(C.amZ(l,n,d.a,d.b),$async$Bq)
case 7:p=g
if(!p){q.BG()
q.pU(D.k3)}r.push(6)
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
return A.p($async$Bq,v)},
BG(){var w=this,v=w.e
if(v!=null)v.ak(0)
w.e=null
v=w.d
if(v!=null)v.ak(0)
w.f=w.d=null},
pU(d){if(this.a===d)return
this.a=d
this.T()}}
C.LX.prototype={
L(){return new C.Tx(B.eu,null,!1)}}
C.Tx.prototype={
U(){var w=this
w.a9()
w.jA()
w.j_(w.gFN())},
b7(){var w,v,u=this
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
return A.h(C.alG(q),$async$jA)
case 7:p=e
if(r.c!=null)r.p(new C.bbv(r,p))
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
vC(d,e){return this.ao3(d,e)},
ao3(d,e){var w=0,v=A.q(x.H),u=1,t=[],s=[],r=this,q,p,o,n,m,l,k
var $async$vC=A.m(function(f,g){if(f===1){t.push(g)
w=u}for(;;)switch(w){case 0:m=J.a7(d)
l=A.bV(m.h(d,"id"))
r.p(new C.bbt(r,l))
o=r.c
o.toString
o=A.af(o,!1,x.d).c
o.toString
q=o
u=3
w=e?6:8
break
case 6:w=9
return A.h(C.al6(q,l),$async$vC)
case 9:o=r.c
if(o!=null)A.b1(o,"Order #"+A.k(m.h(d,"order_id"))+" is yours. Find it in My Deliveries for your pickup code.",!1)
r.a.c.$0()
w=7
break
case 8:w=10
return A.h(C.all(q,l),$async$vC)
case 10:case 7:s.push(5)
w=4
break
case 3:u=2
k=t.pop()
p=A.a3(k)
m=r.c
if(m!=null)A.b1(m,A.b9(p),!0)
s.push(5)
w=4
break
case 2:s=[1]
case 4:u=1
if(r.c!=null)r.p(new C.bbu(r))
w=11
return A.h(r.jA(),$async$vC)
case 11:w=s.pop()
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$vC,v)},
t(d){var w,v,u,t,s,r,q=this,p=null
if(J.d6(q.d))return B.aI
w=A.a([A.j("Requests for you",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.v:B.u,p,p,p,p,p,p,p,p,17,p,p,B.B,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),B.a3],x.p)
for(v=J.bt(q.d),u=q.gFN();v.B();){t=v.gO(v)
s=q.e
r=J.B(t,"id")
w.push(new C.abS(t,s==null?r==null:s===r,new C.bbw(q,t),u,p))}return new A.a0(D.vN,A.U(w,B.q,D.aqw,B.e,B.f,0,B.k),p)}}
C.abS.prototype={
t(a1){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="total_amount",i="restaurant_address",h=A.c(a1).ax.a===B.c?B.v:B.u,g=A.c(a1).ax.a===B.c?B.t:B.r,f=Date.now(),e=l.c,d=J.a7(e),a0=A.ci(d.h(e,"seconds_left"))
a0=a0==null?k:B.h.b5(a0)
w=new A.cm(f,0,!1).pv(A.eL(0,0,a0==null?0:a0).a)
f=x.g.a(d.h(e,"items"))
if(f==null)f=B.bm
v=J.en(f,new C.b2U(),x.N).b9(0,", ")
f=A.k(d.h(e,"id"))
a0=x.O
u=A.bS(a1)
t=A.W(18)
s=A.aZ(B.m,B.n,1.5)
r=A.a([new A.d8(0,B.bA,B.m.N(0.18),B.qT,16)],x.V)
q=d.h(e,"restaurant_name")
p=x.p
q=A.a([D.Yo,B.ad,A.ad(A.j(A.k(q==null?"A restaurant":q)+" asked you",k,k,k,k,A.t(k,k,h,k,k,k,k,k,k,k,k,15,k,k,B.B,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k),1)],p)
if(A.fK(d.h(e,j))){o=A.bz(A.bV(d.h(e,j)))
q.push(A.j(o,k,k,k,k,A.t(k,k,A.c(a1).ax.a===B.c?B.m:B.ao,k,k,k,k,k,k,k,k,k,k,k,B.B,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}q=A.V(q,B.i,k,B.e,B.f,0,k)
o=A.k(d.h(e,"order_id"))
n=v.length===0?"":" \xb7 "+v
n=A.a([q,B.aG,A.j("Order #"+o+n,k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],p)
if(d.h(e,i)!=null)n.push(A.j("Pick up: "+A.k(d.h(e,i)),k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))
n.push(B.N)
n.push(new E.A6(w,new C.b2V(l,g),k))
n.push(B.N)
q=A.k(d.h(e,"id"))
o=l.d
m=o?k:new C.b2W(l)
m=A.ad(A.t5(D.alY,new A.y("rider-offer-decline-"+q,a0),m,k),1)
e=A.k(d.h(e,"id"))
d=o?k:new C.b2X(l)
n.push(A.V(A.a([m,B.ac,A.ad(new A.cK("Accept delivery",d,o,k,new A.y("rider-offer-accept-"+e,a0)),2)],p),B.i,k,B.e,B.f,0,k))
return A.a2(k,A.U(n,B.q,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(u,k,s,t,r,k,B.o),k,k,new A.y("rider-offer-card-"+f,a0),B.bY,B.b8,k,k,k)}}
C.aiS.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a2()}}
C.LZ.prototype={
L(){return new C.Ty()}}
C.Ty.prototype={
U(){this.a9()
this.h5()},
h5(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$h5=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
q=A.af(n,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(E.Xs(q),$async$h5)
case 7:p=e
if(r.c!=null)r.p(new C.bbA(r,p))
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
zJ(){var w=0,v=A.q(x.H),u=this,t
var $async$zJ=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:t=u.c
t.toString
w=4
return A.h(A.dM(t,new E.qA(!0,null),x.P),$async$zJ)
case 4:w=e!=null?2:3
break
case 2:w=5
return A.h(u.h5(),$async$zJ)
case 5:case 3:return A.o(null,v)}})
return A.p($async$zJ,v)},
t(a5){var w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,a0="status",a1="paid",a2="failed",a3="order_count",a4=this.d
if(a4==null)return B.aI
w=A.c(a5).ax.a===B.c?B.v:B.u
v=A.c(a5).ax.a===B.c?B.t:B.r
u=J.a7(a4)
t=J.f(u.h(a4,"payout_mode"),"automatic")
s=E.ajT(a4)
r=x.g.a(u.h(a4,"payouts"))
if(r==null)r=B.bm
q=J.eT(r,x.P)
r=A.bS(a5)
p=A.W(18)
o=A.aZ(A.c(a5).ax.a===B.c?B.E:B.F,B.n,1)
n=A.j("Waiting to be paid",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
m=A.ci(u.h(a4,"owed"))
m=m==null?d:B.h.b5(m)
l=x.p
m=A.ad(A.U(A.a([n,A.j(A.bz(m==null?0:m),D.apZ,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,22,d,d,B.dw,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)
n=A.j("Paid to you",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
k=A.ci(u.h(a4,"paid_total"))
k=k==null?d:B.h.b5(k)
n=A.V(A.a([m,A.ad(A.U(A.a([n,A.j(A.bz(k==null?0:k),d,d,d,d,D.ai8,d,d,d,d)],l),B.q,d,B.e,B.f,0,B.k),1)],l),B.i,d,B.e,B.f,0,d)
u=A.ci(u.h(a4,"rider_share_percent"))
u=H.hu(u==null?100:u)
m=t?"after each delivery":"weekly"
m=A.a([n,B.ae,A.j("You earn "+u+" of each delivery fee, paid "+m+".",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,1.4,!0,d,d,d,d,d,d,d,d),d,d,d,d),B.N],l)
u=this.ganD()
if(s==null)m.push(A.bv(I.a_i(G.xk,D.ap9,D.an6,u),d,1/0))
else{n=A.W(10)
k=A.ad(A.j("Paid to "+s,d,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,13.5,d,d,B.a1,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d),1)
m.push(A.dq(!1,n,!0,A.V(A.a([D.Ye,B.ad,k,A.j("Change",d,d,d,d,A.t(d,d,A.c(a5).ax.a===B.c?B.m:B.ao,d,d,d,d,d,d,d,d,13,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d,!0,d,d,d,d,d,d,d,d,d,d,d,u,d,d,d,d,d,d,d))}if(!q.gaf(q)){u=A.a([A.hS(A.c(a5).ax.a===B.c?B.E:B.F,24,d)],l)
for(n=A.hb(q,0,A.kV(3,"count",x.S),q.$ti.i("am.E")),k=n.$ti,n=new A.be(n,n.gC(0),k.i("be<aK.E>")),k=k.i("aK.E");n.B();){j=n.d
if(j==null)j=k.a(j)
i=J.a7(j)
if(J.f(i.h(j,a0),a1))h=B.cC
else h=J.f(i.h(j,a0),a2)?B.lP:B.hV
if(J.f(i.h(j,a0),a1))g=B.H
else g=J.f(i.h(j,a0),a2)?B.G:B.ab
g=A.ao(h,g,d,d,16)
h=A.bz(B.h.b5(A.bH(i.h(j,"amount"))))
f=A.k(i.h(j,a3))
e=J.f(i.h(j,a3),1)?"y":"ies"
h=A.j(h+" \xb7 "+f+" deliver"+e,d,d,d,d,new A.x(!0,w,d,d,d,d,13,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)
if(J.f(i.h(j,a0),a1))j=H.bo3(i.h(j,"paid_at"))
else j=J.f(i.h(j,a0),a2)?"Failed":"Sending\u2026"
u.push(new A.a0(F.oT,A.V(A.a([g,B.ad,new A.dp(1,B.b1,h,d),A.j(j,d,d,d,d,new A.x(!0,v,d,d,d,d,12,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d))}B.b.H(m,u)}return A.a2(d,A.U(m,B.q,d,B.e,B.f,0,B.k),B.j,d,d,new A.X(r,d,o,p,d,d,B.o),d,d,D.as0,B.vx,B.dQ,d,d,1/0)}}
C.M_.prototype={
L(){var w=$.aa()
return new C.TE(new A.bs(B.a6,w),new A.bs(B.a6,w),new A.bs(B.a6,w),new A.bs(B.a6,w),new A.bs(B.a6,w))},
hf(d){return this.d.$1(d)}}
C.TE.prototype={
U(){var w,v,u,t=this
t.a9()
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
u.R8$=$.aa()
u.p4$=0}t.a2()},
Bf(){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p,o
var $async$Bf=A.m(function(d,e){if(d===1){t.push(e)
w=u}for(;;)switch(w){case 0:u=3
q=s.c
q.toString
q=A.af(q,!1,x.d).c
q.toString
w=6
return A.h(C.Xy(q),$async$Bf)
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
return A.p($async$Bf,v)},
I2(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g,f
var $async$I2=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.x
g=h==="motorbike"||h==="car"
h=A.cE("^GHA-?\\d{9}-?\\d$",!1,!1)
n=q.d
m=B.d.a4(n.a.a)
if(!h.b.test(m)){h=q.c
h.toString
A.b1(h,"Enter your Ghana Card number, e.g. GHA-123456789-0.",!0)
w=1
break}if(g)h=B.d.a4(q.e.a.a).length<4||B.d.a4(q.f.a.a).length<4
else h=!1
if(h){h=q.c
h.toString
A.b1(h,"Add your licence number and number plate.",!0)
w=1
break}h=q.r
if(B.d.a4(h.a.a).length<2||B.d.a4(q.w.a.a).length<9){h=q.c
h.toString
A.b1(h,"Add someone we can call in an emergency.",!0)
w=1
break}q.p(new C.bc1(q))
t=4
m=q.c
m.toString
m=A.af(m,!1,x.d).c
m.toString
n=B.d.a4(n.a.a)
l=q.x
k=g?B.d.a4(q.e.a.a):null
j=g?B.d.a4(q.f.a.a):null
w=7
return A.h(C.amT(m,A.K(["ghana_card",n,"vehicle",l,"licence_number",k,"plate",j,"emergency_name",B.d.a4(h.a.a),"emergency_phone",B.d.a4(q.w.a.a)],x.N,x.z)),$async$I2)
case 7:p=e
q.a.hf(p)
h=q.c
if(h!=null)A.b1(h,"Sent! We'll let you know once you're approved.",!1)
r.push(6)
w=5
break
case 4:t=3
f=s.pop()
o=A.a3(f)
h=q.c
if(h!=null)A.b1(h,A.b9(o),!0)
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bc2(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$I2,v)},
t(d){var w,v,u,t,s,r,q,p,o,n,m,l,k,j=this,i=null,h=j.a.c,g=J.a7(h),f=A.k(g.h(h,"status")),e=x.g.a(g.h(h,"missing"))
if(e==null)e=B.bm
w=J.en(e,new C.bc4(),x.N).ij(0)
v=A.af(d,!0,x.d)
u=A.c(d).ax.a===B.c?B.v:B.u
t=A.c(d).ax.a===B.c?B.t:B.r
s=new C.bc7(d,t,u)
e=v.f
if(e==null)e=""
r=f==="pending"
e=A.IU(e,F.vP,"rider",r?"We're checking your details.":"Let's get you verified so you can start earning.")
q=x.p
p=A.a([],q)
if(r)p.push(new C.DO(B.fq,B.lQ,"Thanks! Your details are with FindFood","We may call you to meet and see your Ghana Card"+(J.f(g.h(h,"vehicle"),"motorbike")||J.f(g.h(h,"vehicle"),"car")?" and licence":"")+". You'll get a notification as soon as you're approved.",D.at5))
else{r=A.a([],q)
o=f==="rejected"
if(o){g=g.h(h,"rejection_reason")
r.push(new C.DO(B.G,D.Wb,"We couldn't approve you yet",A.k(g==null?"Please check your details.":g)+". Fix it below and send again.",D.atb))}else r.push(D.auk)
r.push(B.a2)
r.push(s.$4(1,"A clear photo of your face",!w.m(0,"photo"),D.TT))
r.push(s.$4(2,"Your phone number",!w.m(0,"phone"),A.c2(D.and,D.aq9,i,i,new C.bc5(j,d),i,i)))
r.push(s.$4(3,"Your ID and vehicle",!1,i))
r.push(B.aG)
r.push(A.cT(j.d,"Ghana Card number (GHA-123456789-0)",D.aqA,i,1,!1,i,D.Ve,i,i,i))
r.push(B.N)
r.push(A.j("How do you deliver?",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a3)
g=A.a([],q)
for(n=D.Da.gha(D.Da),n=n.gal(n),m=x.O;n.B();){l=n.gO(n)
k=l.a
g.push(A.r3(i,i,new A.y("vehicle-"+k,m),A.j(l.b,i,i,i,i,i,i,i,i,i),i,new C.bc6(j,l),j.x===k,i,i,i,i))}r.push(A.fH(B.bo,g,B.bK,8,8))
g=j.x
if(g==="motorbike"||g==="car")B.b.H(r,A.a([B.N,A.cT(j.e,"Driver's licence number",D.apf,i,1,!1,i,B.wS,i,i,i),B.ae,A.cT(j.f,"Number plate, e.g. GR 1234-24",D.aqs,i,1,!1,i,B.lK,i,i,i)],q))
r.push(B.a2)
r.push(A.j("Emergency contact",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a3)
r.push(A.cT(j.r,"Their name",D.ar2,i,1,!1,i,B.dU,i,i,i))
r.push(B.ae)
r.push(A.cT(j.w,"Their phone number",D.asO,B.iq,1,!1,i,B.lJ,i,i,i))
r.push(B.a3)
r.push(A.j("Only FindFood admins see these details. We never share your Ghana Card number.",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,12,i,i,i,i,1.4,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a2)
g=o?"Send again":"Send for approval"
o=j.y
r.push(new A.cK(g,o||w.a!==0?i:j.gaFh(),o,i,D.arA))
if(w.a!==0)r.push(new A.a0(B.jd,A.j("Add your photo and phone number first (steps 1 and 2).",i,i,i,i,A.t(i,i,A.c(d).ax.a===B.c?B.m:B.ao,i,i,i,i,i,i,i,i,12.5,i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i),i))
B.b.H(p,r)}return A.ex(A.dE(A.a([e,new A.a0(B.lq,A.U(p,B.q,i,B.e,B.f,0,B.k),i)],q),i,i,D.S6,i,B.V,!1),B.m,j.gaEw())}}
C.DO.prototype={
t(d){var w,v,u=this,t=null,s=u.c,r=s.N(0.1),q=A.W(14),p=A.aZ(s.N(0.35),B.n,1)
s=A.ao(u.d,s,t,t,22)
w=A.j(u.e,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.v:B.u,t,t,t,t,t,t,t,t,t,t,t,B.B,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)
v=x.p
return A.a2(t,A.V(A.a([s,B.ac,A.ad(A.U(A.a([w,B.h2,A.j(u.f,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.c?B.t:B.r,t,t,t,t,t,t,t,t,13,t,t,t,t,1.4,!0,t,t,t,t,t,t,t,t),t,t,t,t)],v),B.q,t,B.e,B.f,0,B.k),1)],v),B.q,t,B.e,B.f,0,t),B.j,t,t,new A.X(r,t,p,q,t,t,B.o),t,t,t,t,B.bl,t,t,1/0)}}
var z=a.updateTypes(["ap<~>()","tB(@)","ap<~>({silent:M})","d(tB)","~(jR)"])
C.aF8.prototype={
$1(d){var w,v,u,t,s="completed_at"
x.P.a(d)
w=J.a7(d)
v=w.h(d,"order_id")
u=w.h(d,"restaurant_name")
w.h(d,"delivery_address")
t=w.h(d,"earning")
if(t==null)t=0
if(w.h(d,s)==null)w=null
else{w=A.iP(J.bJ(w.h(d,s)))
w=w==null?null:w.hF()}return new C.tB(v,u,t,w)},
$S:z+1}
C.bbe.prototype={
$1(d){var w=this.a
return w.p(new C.bbd(w,d))},
$S:10}
C.bbd.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.aPa.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aPg.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.aPh.prototype={
$0(){return this.a.f=!this.b},
$S:0}
C.aP9.prototype={
$0(){return this.a.r=C.btU(this.b)},
$S:0}
C.aPl.prototype={
$1(d){return this.a.HE()},
$S:30}
C.aPm.prototype={
$1(d){},
$S:13}
C.aPb.prototype={
$0(){var w=this.a
w.e=!0
w.x=""},
$S:0}
C.aPc.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.ba(v)},
$S:0}
C.aPd.prototype={
$0(){return this.a.x=A.b9(this.b)},
$S:0}
C.aPe.prototype={
$0(){return this.a.e=!1},
$S:0}
C.aPf.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.ba(v)},
$S:0}
C.aP6.prototype={
$0(){return J.zg(this.a.d,new C.aP5(this.b))},
$S:0}
C.aP5.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aPj.prototype={
$1(d){var w=this.a
return w.p(new C.aPi(w,d))},
$S:46}
C.aPi.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aPk.prototype={
$2(d,e){var w=this.a
return w.art(J.B(w.d,e))},
$S:97}
C.aP7.prototype={
$0(){return this.a.ob(this.b)},
$S:0}
C.aP8.prototype={
$0(){return this.a.FF(this.b)},
$S:0}
C.b2l.prototype={
$0(){return this.a.wv(!0)},
$S:2}
C.b27.prototype={
$0(){var w=this.a
w.e=!0
w.f=""},
$S:0}
C.b28.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.b29.prototype={
$0(){return this.a.f=A.b9(this.b)},
$S:0}
C.b2a.prototype={
$0(){return this.a.e=!1},
$S:0}
C.b2i.prototype={
$1(d){var w=null,v=A.j("Release order #"+this.a.a+"?",w,w,w,w,w,w,w,w,w)
return A.fN(A.a([A.c2(D.amS,w,w,w,new C.b2g(d),w,w),A.c2(D.amY,D.arS,w,w,new C.b2h(d),w,w)],x.p),w,D.al_,!1,w,v)},
$S:16}
C.b2g.prototype={
$0(){A.b_(this.a,!1).aX(!1)
return null},
$S:0}
C.b2h.prototype={
$0(){A.b_(this.a,!1).aX(!0)
return null},
$S:0}
C.b2j.prototype={
$0(){return J.zg(this.a.d,new C.b2f(this.b))},
$S:0}
C.b2f.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b26.prototype={
$1(d){return this.afv(d)},
afv(d){var w=0,v=A.q(x.H),u,t=this,s,r,q
var $async$$1=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=t.c
w=3
return A.h(E.zs(t.b,"/orders/"+s.a+"/deliver","Could not complete this delivery.",d),$async$$1)
case 3:r=f
q=t.a
if(q.c==null){w=1
break}q.p(new C.b25(q,s,r))
case 1:return A.o(u,v)}})
return A.p($async$$1,v)},
$S:56}
C.b25.prototype={
$0(){var w=this.a,v=J.X0(w.d,new C.b24(this.b))
if(v!==-1)J.eJ(w.d,v,this.c)},
$S:0}
C.b24.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b2k.prototype={
$2(d,e){var w=this.a
return w.aB_(J.B(w.d,e))},
$S:97}
C.b2b.prototype={
$0(){var w,v,u=this.a.c
u.toString
w=this.b
v=w.f
return A.FU(u,w.a,A.a([D.Ot,new A.l6("restaurant",v==null?"Restaurant":v,"Collecting the order")],x.J))},
$S:0}
C.b2c.prototype={
$0(){return this.a.ob(this.b)},
$S:0}
C.b2d.prototype={
$0(){return this.a.Bj(this.b)},
$S:0}
C.b2e.prototype={
$0(){return this.a.G_(this.b)},
$S:0}
C.bbm.prototype={
$0(){var w=this.a
w.f=!0
w.e=null},
$S:0}
C.bbn.prototype={
$0(){return this.a.d=C.btU(this.b)},
$S:0}
C.bbo.prototype={
$0(){return this.a.e=A.b9(this.b)},
$S:0}
C.bbp.prototype={
$0(){return this.a.f=!1},
$S:0}
C.bc0.prototype={
$0(){return A.dM(this.a,new E.qA(!0,null),x.P)},
$S:0}
C.bdq.prototype={
$2(d,e){var w,v,u,t,s,r,q,p=null,o=this.a,n=o.a
if(n===D.k3)return B.aI
w=n===D.Ib
v=w?B.H:B.ab
u=v.N(0.1)
t=A.W(14)
s=A.aZ(v.N(0.35),B.n,1)
r=A.ao(w?B.q1:D.We,v,p,p,20)
q=w?"The customer can see you on the map. Keep FindFood open while you deliver.":"Turn on location so the customer can see you coming."
r=A.a([r,B.ac,A.ad(A.j(q,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.c?B.v:B.u,p,p,p,p,p,p,p,p,13,p,p,B.a1,p,1.35,!0,p,p,p,p,p,p,p,p),p,p,p,p),1)],x.p)
if(!w)r.push(A.c2(D.amB,D.aqH,p,p,o.gaVm(),p,p))
return A.a2(p,A.V(r,B.i,p,B.e,B.f,0,p),B.j,p,p,new A.X(u,p,s,t,p,p,B.o),p,p,D.ar7,D.vN,D.SG,p,p,p)},
$S:47}
C.alD.prototype={
$1(d){return A.BH(d)},
$S:234}
C.aFf.prototype={
$1(d){return this.a.fZ(0)},
$S:30}
C.aFe.prototype={
$1(d){return d.ch!=null&&d.r==="delivery"&&B.b.m(F.xO,d.c)},
$S:23}
C.aFc.prototype={
$1(d){var w=this.a
w.BG()
w.pU(D.mT)},
$S:13}
C.aFd.prototype={
$1(d){var w=this.a,v=w.f
if(v!=null)w.Bq(v,!0)},
$S:30}
C.bbv.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bbt.prototype={
$0(){return this.a.e=this.b},
$S:0}
C.bbu.prototype={
$0(){return this.a.e=null},
$S:0}
C.bbw.prototype={
$1(d){return this.a.vC(this.b,d)},
$S:6}
C.b2U.prototype={
$1(d){var w=J.a7(d)
return A.k(w.h(d,"quantity"))+"\xd7 "+A.k(w.h(d,"name"))},
$S:101}
C.b2V.prototype={
$2(d,e){var w,v,u,t=null,s=e.a
if(s===0)$.aj.aQ$.push(new C.b2T(this.a))
w=A.W(4)
s=B.l.bY(s,1e6)
v=s>30?B.m:B.G
u=A.c(d).ax.a===B.c?B.E:B.F
return A.U(A.a([A.fO(w,E.bsA(u,v,5,s/180,t)),B.aF,A.j(E.bxM(e)+" left to answer",t,t,t,t,A.t(t,t,this.b,t,t,t,t,t,t,t,t,12,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)],x.p),B.q,t,B.e,B.f,0,B.k)},
$S:755}
C.b2T.prototype={
$1(d){return this.a.f.$0()},
$S:4}
C.b2W.prototype={
$0(){return this.a.e.$1(!1)},
$S:0}
C.b2X.prototype={
$0(){return this.a.e.$1(!0)},
$S:0}
C.bbA.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bc1.prototype={
$0(){return this.a.y=!0},
$S:0}
C.bc2.prototype={
$0(){return this.a.y=!1},
$S:0}
C.bc4.prototype={
$1(d){return A.k(d)},
$S:101}
C.bc7.prototype={
$4(d,e,f,g){var w,v,u,t=this,s=null
if(f)w=B.H
else w=A.c(t.a).ax.a===B.c?B.ar:B.aq
if(f)v=B.H
else v=A.c(t.a).ax.a===B.c?B.E:B.F
v=A.aZ(v,B.n,1)
u=f?D.XK:A.j(""+d,s,s,s,s,A.t(s,s,t.b,s,s,s,s,s,s,s,s,s,s,s,B.B,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s)
v=A.a2(B.a5,u,B.j,s,s,new A.X(w,s,v,s,s,s,B.av),s,28,s,s,s,s,s,28)
w=f?B.Jc:s
w=A.a([v,B.aC,A.ad(A.j(e,s,s,s,s,A.t(s,s,t.c,s,w,s,s,s,s,s,s,s,s,s,B.z,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s),1)],x.p)
if(!f&&g!=null)w.push(g)
return new A.a0(B.bY,A.V(w,B.i,s,B.e,B.f,0,s),s)},
$S:756}
C.bc5.prototype={
$0(){var w=0,v=A.q(x.H),u=this
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:w=2
return A.h(A.dM(u.b,B.ti,x.H),$async$$0)
case 2:w=3
return A.h(u.a.Bf(),$async$$0)
case 3:return A.o(null,v)}})
return A.p($async$$0,v)},
$S:2}
C.bc6.prototype={
$1(d){var w=this.a
return w.p(new C.bc3(w,this.b))},
$S:6}
C.bc3.prototype={
$0(){return this.a.x=this.b.a},
$S:0};(function installTearOffs(){var w=a._instance_0u,v=a.installInstanceTearOff,u=a._instance_1u
var t
w(t=C.OB.prototype,"gaIs","IB",0)
w(t,"gwu","j6",0)
v(C.Ru.prototype,"gwu",0,0,null,["$1$silent","$0"],["wv","j6"],2,0,0)
w(t=C.Tw.prototype,"gwu","j6",0)
u(t,"gaEm","aEn",3)
w(t=C.LW.prototype,"gaVm","Mk",0)
u(t,"gaAV","aAW",4)
w(C.Tx.prototype,"gFN","jA",0)
w(C.Ty.prototype,"ganD","zJ",0)
w(t=C.TE.prototype,"gaEw","Bf",0)
w(t,"gaFh","I2",0)})();(function inheritance(){var w=a.mixinHard,v=a.inheritMany,u=a.inherit
v(A.R,[C.tB,C.aF7])
v(A.im,[C.aF8,C.bbe,C.aPl,C.aPm,C.aP5,C.aPj,C.b2i,C.b2f,C.b26,C.b24,C.alD,C.aFf,C.aFe,C.aFc,C.aFd,C.bbw,C.b2U,C.b2T,C.bc4,C.bc7,C.bc6])
v(A.N,[C.tA,C.OA,C.Rt,C.Tv,C.LX,C.LZ,C.M_])
v(A.O,[C.aey,C.OB,C.aii,C.Tw,C.aiS,C.Ty,C.TE])
v(A.nc,[C.bbd,C.aPa,C.aPg,C.aPh,C.aP9,C.aPb,C.aPc,C.aPd,C.aPe,C.aPf,C.aP6,C.aPi,C.aP7,C.aP8,C.b2l,C.b27,C.b28,C.b29,C.b2a,C.b2g,C.b2h,C.b2j,C.b25,C.b2b,C.b2c,C.b2d,C.b2e,C.bbm,C.bbn,C.bbo,C.bbp,C.bc0,C.bbv,C.bbt,C.bbu,C.b2W,C.b2X,C.bbA,C.bc1,C.bc2,C.bc5,C.bc3])
v(A.oX,[C.aPk,C.b2k,C.bdq,C.b2V])
u(C.Ru,C.aii)
v(A.a5,[C.aeC,C.afm,C.abS,C.DO])
u(C.Mz,A.yu)
u(C.LW,A.b2)
u(C.Tx,C.aiS)
w(C.aii,H.hB)
w(C.aiS,H.hB)})()
A.z1(b.typeUniverse,JSON.parse('{"OA":{"N":[],"d":[],"e":[]},"Rt":{"N":[],"d":[],"e":[]},"Tv":{"N":[],"d":[],"e":[]},"tA":{"N":[],"d":[],"e":[]},"aey":{"O":["tA"]},"OB":{"O":["OA"]},"Ru":{"O":["Rt"]},"Tw":{"O":["Tv"]},"aeC":{"a5":[],"d":[],"e":[]},"afm":{"a5":[],"d":[],"e":[]},"LW":{"b2":[],"aA":[]},"LX":{"N":[],"d":[],"e":[]},"Tx":{"O":["LX"]},"abS":{"a5":[],"d":[],"e":[]},"LZ":{"N":[],"d":[],"e":[]},"Ty":{"O":["LZ"]},"M_":{"N":[],"d":[],"e":[]},"TE":{"O":["M_"]},"DO":{"a5":[],"d":[],"e":[]}}'))
var y={a:"https://findfooddelivery-backend.onrender.com/deliveries/offers/",d:"https://findfooddelivery-backend.onrender.com/riders/me/verification"}
var x=(function rtii(){var w=A.aH
return{d:w("l3"),f:w("rs"),V:w("D<d8>"),J:w("D<l6>"),A:w("D<eZ>"),s:w("D<r>"),p:w("D<d>"),D:w("Z<aD<r,@>>"),l:w("Z<eZ>"),j:w("Z<@>"),P:w("aD<r,@>"),W:w("eZ"),L:w("tB"),N:w("r"),O:w("y<r>"),q:w("ut"),y:w("M"),i:w("Y"),z:w("@"),S:w("A"),g:w("Z<@>?"),Q:w("t1?"),H:w("~")}})();(function constants(){var w=a.makeConstList
D.L4=new I.zj("Rider",null)
D.Ot=new A.l6("customer","Customer","Directions and delivery updates")
D.S6=new A.a1(0,0,0,40)
D.S8=new A.a1(0,0,12,0)
D.SG=new A.a1(14,12,10,12)
D.SN=new A.a1(15,0,0,0)
D.vI=new A.a1(16,12,16,12)
D.SS=new A.a1(16,12,16,8)
D.vN=new A.a1(20,0,20,14)
D.TT=new I.An(44,null)
D.Vr=new A.a4(61734,"MaterialIcons",null,!1)
D.TZ=new A.d9(D.Vr,"No deliveries right now","Stay online \u2014 new jobs appear as orders come in.",null,null,null)
D.U2=new A.d9(B.dS,"You're offline","Go online to start seeing available deliveries.",null,null,null)
D.U3=new A.d9(B.dS,"No deliveries yet","Accept a job from Available tab to get started.",null,null,null)
D.na=new A.x(!0,null,null,"PlusJakartaSans",null,null,28,B.B,null,-0.8,null,null,1.15,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ale=new A.al("Available jobs",null,D.na,null,null,B.a4,null,null,null,null,null)
D.alN=new A.al("Tap a job to accept it",null,B.JB,null,null,null,null,null,null,null,null)
D.a3z=w([D.ale,B.br,D.alN],x.p)
D.Qq=new A.l8(B.V,B.e,B.f,B.q,null,B.k,null,0,D.a3z,null)
D.Uc=new A.dp(1,B.b1,D.Qq,null)
D.Ve=new A.a4(61112,"MaterialIcons",null,!1)
D.Vt=new A.a4(61838,"MaterialIcons",null,!1)
D.wF=new A.a4(61958,"MaterialIcons",null,!1)
D.Wb=new A.a4(63510,"MaterialIcons",null,!1)
D.We=new A.a4(63618,"MaterialIcons",null,!1)
D.X9=new A.aP(F.jp,18,B.x,null,null)
D.XD=new A.aP(B.fC,18,B.H,null,null)
D.XK=new A.aP(B.fD,16,B.y,null,null)
D.XO=new A.aP(B.W9,16,B.H,null,null)
D.Y0=new A.aP(B.cp,16,B.m,null,null)
D.Ya=new A.aP(B.lK,18,B.x,null,null)
D.Ye=new A.aP(B.fF,18,B.H,null,null)
D.Yo=new A.aP(B.cp,20,B.aB,null,null)
D.Yq=new A.aP(F.xc,18,null,null,null)
D.Vk=new A.a4(61495,"MaterialIcons",null,!1)
D.awU=new A.a4(63268,"MaterialIcons",null,!1)
D.UO=new A.hy(D.Vk,"Available",0)
D.UP=new A.hy(B.dS,"My Deliveries",0)
D.UJ=new A.hy(B.hR,"Earnings",0)
D.a3l=w([D.UO,D.UP,D.UJ,B.ws],A.aH("D<hy>"))
D.a3P=new A.Bi(B.a3N,10,null)
D.a6C={motorbike:0,bicycle:1,car:2,on_foot:3}
D.Da=new A.bC(D.a6C,["Motorbike","Bicycle","Car","On foot"],A.aH("bC<r,r>"))
D.alj=new A.al("My deliveries",null,D.na,null,null,null,null,null,null,null,null)
D.a7M=new A.a0(B.oY,D.alj,null)
D.Sp=new A.a1(0,60,0,0)
D.a7Q=new A.a0(D.Sp,B.bW,null)
D.ab_=new C.LZ(null)
D.XY=new A.aP(B.q2,18,B.x,null,null)
D.amb=new A.al("New delivery available!",null,G.Jj,null,null,null,null,null,null,null,null)
D.a3b=w([D.XY,B.ad,D.amb],x.p)
D.ab5=new A.ja(B.aK,B.e,B.f,B.i,null,B.k,null,0,D.a3b,null)
D.k3=new C.Mz(0,"idle")
D.Ib=new C.Mz(1,"sharing")
D.mT=new C.Mz(2,"blocked")
D.amy=new A.al("Could not open maps.",null,null,null,null,null,null,null,null,null,null)
D.IQ=new A.fV(D.amy,null,null,null,null,null,null,null,null,null,null,null,null,B.ag,!1,null,null,null,B.A,null)
D.akS=new A.al("Delivery complete. Nice work!",null,B.b3,null,null,null,null,null,null,null,null)
D.ael=new A.fV(D.akS,B.H,null,null,null,null,null,null,null,null,null,null,null,B.ag,!1,null,null,null,B.A,null)
D.amt=new A.al("This order does not have a delivery destination.",null,null,null,null,null,null,null,null,null,null)
D.IR=new A.fV(D.amt,null,null,null,null,null,null,null,null,null,null,null,null,B.ag,!1,null,null,null,B.A,null)
D.n9=new A.x(!0,null,null,"PlusJakartaSans",null,null,12,B.ax,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ai8=new A.x(!0,B.H,null,null,null,null,22,B.dw,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.nb=new A.x(!0,null,null,"PlusJakartaSans",null,null,16,B.z,null,-0.1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.kj=new A.x(!0,null,null,"PlusJakartaSans",null,null,13,B.a1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.akM=new A.al("Earned today",null,D.kj,null,null,null,null,null,null,null,null)
D.akT=new A.al("Release this job",null,null,null,null,null,null,null,null,null,null)
D.al_=new A.al("It goes back to the available jobs for another rider. You can release up to 2 jobs a day, and never after collecting the food.",null,null,null,null,null,null,null,null,null,null)
D.ald=new A.al("Complete with customer's code",null,null,null,null,null,null,null,null,null,null)
D.alY=new A.al("Decline",null,null,null,null,null,null,null,null,null,null)
D.am5=new A.al("Earnings",null,D.na,null,null,null,null,null,null,null,null)
D.am9=new A.al("Recent deliveries",null,B.Ju,null,null,null,null,null,null,null,null)
D.amB=new A.al("Turn on",null,null,null,null,null,null,null,null,null,null)
D.amD=new A.al("Profile",null,D.na,null,null,null,null,null,null,null,null)
D.amS=new A.al("Keep job",null,null,null,null,null,null,null,null,null,null)
D.amY=new A.al("Release",null,B.ki,null,null,null,null,null,null,null,null)
D.an6=new A.al("Add your MoMo to get paid",null,null,null,null,null,null,null,null,null,null)
D.an8=new A.al("Accept delivery",null,null,null,null,null,null,null,null,null,null)
D.and=new A.al("Add",null,null,null,null,null,null,null,null,null,null)
D.ap9=new A.y("rider-add-payout",x.O)
D.apf=new A.y("verify-licence",x.O)
D.apZ=new A.y("rider-owed",x.O)
D.aq9=new A.y("verification-add-phone",x.O)
D.aqs=new A.y("verify-plate",x.O)
D.aqw=new A.y("rider-offers",x.O)
D.aqA=new A.y("verify-card",x.O)
D.aqH=new A.y("rider-sharing-retry",x.O)
D.ar2=new A.y("verify-emergency-name",x.O)
D.ar7=new A.y("rider-sharing-banner",x.O)
D.arA=new A.y("verify-submit",x.O)
D.arS=new A.y("confirm-release",x.O)
D.as0=new A.y("rider-payout-card",x.O)
D.ask=new A.y("rider-online-toggle",x.O)
D.asO=new A.y("verify-emergency-phone",x.O)
D.at5=new A.y("verification-pending",x.O)
D.atb=new A.y("verification-rejected",x.O)
D.atI=new A.y("settings-rider-payout",x.O)
D.atK=new A.y("rider-today-earnings",x.O)
D.aug=new C.OA(null)
D.Wx=new A.a4(983663,"MaterialIcons",null,!1)
D.auk=new C.DO(B.aB,D.Wx,"Riders are checked before their first job","It keeps customers and restaurants safe. It takes a few minutes to fill in.",null)
D.avE=new C.Rt(null)
D.aw3=new C.Tv(null)
D.aw5=new C.aeC(null)
D.awf=new C.afm(null)})();(function lazyInitializers(){var w=a.lazyFinal
w($,"bSo","ak8",()=>new C.LW(D.k3,$.aa()))})()};
(a=>{a["cBr4eFi1DsvF4QZTu8TqRf+Qsak="]=a.current})($__dart_deferred_initializers__);