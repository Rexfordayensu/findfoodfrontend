((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,E,G,I,K,C={
buM(d){var w,v,u,t,s,r,q=J.a6(d)
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
r=A.ck(q.h(d,"average_rating"))
if(r==null)r=null
q=q.h(d,"recent_deliveries")
if(q==null)q=[]
q=J.eo(x.j.a(q),new C.aFo(),x.L)
q=A.ah(q,q.$ti.i("aL.E"))
return new C.aFn(w,v,u,t,s,r,q)},
tE:function tE(d,e,f,g){var _=this
_.a=d
_.b=e
_.d=f
_.e=g},
aFn:function aFn(d,e,f,g,h,i,j){var _=this
_.c=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j},
aFo:function aFo(){},
bIB(){return new C.tD(null)},
tD:function tD(d){this.a=d},
aeL:function aeL(){this.d=0
this.c=this.a=null},
bc5:function bc5(d){this.a=d},
bc4:function bc4(d,e){this.a=d
this.b=e},
OG:function OG(d){this.a=d},
OH:function OH(d){var _=this
_.d=d
_.f=_.e=!0
_.w=_.r=null
_.x=""
_.y=null
_.z=0
_.c=_.a=null},
aPq:function aPq(d,e){this.a=d
this.b=e},
aPw:function aPw(d,e){this.a=d
this.b=e},
aPx:function aPx(d,e){this.a=d
this.b=e},
aPp:function aPp(d,e){this.a=d
this.b=e},
aPB:function aPB(d){this.a=d},
aPC:function aPC(){},
aPr:function aPr(d){this.a=d},
aPs:function aPs(d,e){this.a=d
this.b=e},
aPt:function aPt(d,e){this.a=d
this.b=e},
aPu:function aPu(d){this.a=d},
aPv:function aPv(d,e){this.a=d
this.b=e},
aPm:function aPm(d,e){this.a=d
this.b=e},
aPl:function aPl(d){this.a=d},
aPz:function aPz(d){this.a=d},
aPy:function aPy(d,e){this.a=d
this.b=e},
aPA:function aPA(d){this.a=d},
aPn:function aPn(d,e){this.a=d
this.b=e},
aPo:function aPo(d,e){this.a=d
this.b=e},
RA:function RA(d){this.a=d},
RB:function RB(d,e,f){var _=this
_.d=d
_.e=!0
_.f=""
_.dO$=e
_.i3$=f
_.c=_.a=null},
b3b:function b3b(d){this.a=d},
b2Y:function b2Y(d){this.a=d},
b2Z:function b2Z(d,e){this.a=d
this.b=e},
b3_:function b3_(d,e){this.a=d
this.b=e},
b30:function b30(d){this.a=d},
b38:function b38(d){this.a=d},
b36:function b36(d){this.a=d},
b37:function b37(d){this.a=d},
b39:function b39(d,e){this.a=d
this.b=e},
b35:function b35(d){this.a=d},
b2X:function b2X(d,e,f){this.a=d
this.b=e
this.c=f},
b2W:function b2W(d,e,f){this.a=d
this.b=e
this.c=f},
b2V:function b2V(d){this.a=d},
b3a:function b3a(d){this.a=d},
b31:function b31(d,e){this.a=d
this.b=e},
b32:function b32(d,e){this.a=d
this.b=e},
b33:function b33(d,e){this.a=d
this.b=e},
b34:function b34(d,e){this.a=d
this.b=e},
TC:function TC(d){this.a=d},
TD:function TD(){var _=this
_.e=_.d=null
_.f=!0
_.c=_.a=null},
bcd:function bcd(d){this.a=d},
bce:function bce(d,e){this.a=d
this.b=e},
bcf:function bcf(d,e){this.a=d
this.b=e},
bcg:function bcg(d){this.a=d},
aeP:function aeP(d){this.a=d},
bcS:function bcS(d){this.a=d},
afz:function afz(d){this.a=d},
beh:function beh(d){this.a=d},
aiv:function aiv(){},
Xt(d){var w=0,v=A.q(x.l),u,t,s
var $async$Xt=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bO("GET",A.aq("https://findfooddelivery-backend.onrender.com/deliveries/available",0,null),A.J(["Authorization","Bearer "+d],t,t)),$async$Xt)
case 3:s=f
t=s.b
if(t===200){t=J.eo(A.f5(s),new C.alS(),x.W)
t=A.ah(t,t.$ti.i("aL.E"))
u=t
w=1
break}throw A.i(A.ag("Failed to load deliveries ("+t+")"))
case 1:return A.o(u,v)}})
return A.p($async$Xt,v)},
XD(d){var w=0,v=A.q(x.P),u,t,s,r
var $async$XD=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bO("GET",A.aq("https://findfooddelivery-backend.onrender.com/riders/me/analytics",0,null),A.J(["Authorization","Bearer "+d],t,t)),$async$XD)
case 3:s=f
r=A.bf(s)
if(s.b===200){u=r
w=1
break}t=J.A(r,"detail")
throw A.i(A.ag(t==null?"Failed to load analytics":t))
case 1:return A.o(u,v)}})
return A.p($async$XD,v)},
XM(d,e){var w=0,v=A.q(x.H),u,t
var $async$XM=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aE().bg("PUT",A.aq("https://findfooddelivery-backend.onrender.com/riders/me/online",0,null),A.J(["Content-Type","application/json","Authorization","Bearer "+d],u,u),B.S.bC(A.J(["online",e],u,x.y),null),null),$async$XM)
case 2:t=g
if(t.b!==200)throw A.i(A.ag(A.bo(t,"Could not change your status")))
return A.o(null,v)}})
return A.p($async$XM,v)},
alV(d){var w=0,v=A.q(x.D),u,t,s
var $async$alV=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bO("GET",A.aq("https://findfooddelivery-backend.onrender.com/deliveries/offers",0,null),A.J(["Authorization","Bearer "+d],t,t)),$async$alV)
case 3:s=f
if(s.b===200){u=A.dN(A.f5(s),!0,x.P)
w=1
break}throw A.i(A.ag(A.bo(s,"Could not load requests")))
case 1:return A.o(u,v)}})
return A.p($async$alV,v)},
all(d,e){var w=0,v=A.q(x.W),u,t,s
var $async$all=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bg("POST",A.aq(y.a+e+"/accept",0,null),A.J(["Authorization","Bearer "+d],t,t),null,null),$async$all)
case 3:s=g
if(s.b===200){u=A.BK(A.bf(s))
w=1
break}throw A.i(A.ag(A.bo(s,"Could not accept the delivery")))
case 1:return A.o(u,v)}})
return A.p($async$all,v)},
alA(d,e){var w=0,v=A.q(x.H),u,t
var $async$alA=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:u=x.N
w=2
return A.h($.aE().bg("POST",A.aq(y.a+e+"/decline",0,null),A.J(["Authorization","Bearer "+d],u,u),null,null),$async$alA)
case 2:t=g
if(t.b!==200)throw A.i(A.ag(A.bo(t,"Could not decline")))
return A.o(null,v)}})
return A.p($async$alA,v)},
XE(d){var w=0,v=A.q(x.P),u,t,s
var $async$XE=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bO("GET",A.aq(y.d,0,null),A.J(["Authorization","Bearer "+d],t,t)),$async$XE)
case 3:s=f
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bo(s,"Could not load your verification")))
case 1:return A.o(u,v)}})
return A.p($async$XE,v)},
an7(d,e){var w=0,v=A.q(x.P),u,t,s
var $async$an7=A.m(function(f,g){if(f===1)return A.n(g,v)
for(;;)switch(w){case 0:t=x.N
w=3
return A.h($.aE().bg("PUT",A.aq(y.d,0,null),A.J(["Content-Type","application/json","Authorization","Bearer "+d],t,t),B.S.bC(e,null),null),$async$an7)
case 3:s=g
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bo(s,"Could not send your details")))
case 1:return A.o(u,v)}})
return A.p($async$an7,v)},
and(d,e,f,g){var w=0,v=A.q(x.y),u,t,s,r,q,p
var $async$and=A.m(function(h,i){if(h===1)return A.n(i,v)
for(;;)switch(w){case 0:s=$.aE()
r=A.aq("https://findfooddelivery-backend.onrender.com/riders/me/location",0,null)
q=x.N
p=A.J(["Authorization","Bearer "+d,"Content-Type","application/json"],q,q)
q=A.E(q,x.i)
q.n(0,"lat",f)
q.n(0,"lng",g)
if(e!=null)q.n(0,"heading",e)
w=3
return A.h(s.bg("PUT",r,p,B.S.bC(q,null),null),$async$and)
case 3:t=i
if(t.b===200){u=J.f(J.A(A.bf(t),"sharing"),!0)
w=1
break}throw A.i(A.ag(A.bo(t,"Could not share your location")))
case 1:return A.o(u,v)}})
return A.p($async$and,v)},
alS:function alS(){},
MF:function MF(d,e){this.a=d
this.b=e},
M1:function M1(d,e){var _=this
_.a=d
_.r=_.f=_.e=_.d=_.c=_.b=null
_.w=!1
_.p4$=0
_.R8$=e
_.rx$=_.RG$=0},
aFv:function aFv(d){this.a=d},
aFu:function aFu(){},
aFs:function aFs(d){this.a=d},
aFt:function aFt(d){this.a=d},
M2:function M2(d,e){this.c=d
this.a=e},
TE:function TE(d,e,f){var _=this
_.d=d
_.e=null
_.f=-1
_.dO$=e
_.i3$=f
_.c=_.a=null},
bcm:function bcm(d,e){this.a=d
this.b=e},
bck:function bck(d,e){this.a=d
this.b=e},
bcl:function bcl(d){this.a=d},
bcn:function bcn(d,e){this.a=d
this.b=e},
ac3:function ac3(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
b3K:function b3K(){},
b3L:function b3L(d,e){this.a=d
this.b=e},
b3J:function b3J(d){this.a=d},
b3M:function b3M(d){this.a=d},
b3N:function b3N(d){this.a=d},
aj4:function aj4(){},
M4:function M4(d){this.a=d},
TF:function TF(){this.c=this.a=this.d=null},
bcr:function bcr(d,e){this.a=d
this.b=e},
M5:function M5(d,e,f){this.c=d
this.d=e
this.a=f},
TL:function TL(d,e,f,g,h){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x="motorbike"
_.y=!1
_.c=_.a=null},
bcT:function bcT(d){this.a=d},
bcU:function bcU(d){this.a=d},
bcW:function bcW(){},
bcZ:function bcZ(d,e,f){this.a=d
this.b=e
this.c=f},
bcX:function bcX(d,e){this.a=d
this.b=e},
bcY:function bcY(d,e){this.a=d
this.b=e},
bcV:function bcV(d,e){this.a=d
this.b=e},
DR:function DR(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bx1(d,e,f,g){var w,v,u,t,s,r,q,p,o,n=null,m=e.length,l="",k=n
if(m!==0){v=0
for(;;){if(!(v<m)){w=0
break}if(e.charCodeAt(v)===64){l=B.d.af(e,0,v)
w=v+1
break}++v}if(w<m&&e.charCodeAt(w)===91){for(u=w,t=-1;u<m;++u){s=e.charCodeAt(u)
if(s===37&&t<0){r=B.d.eg(e,"25",u+1)?u+2:u
t=u
u=r}else if(s===93)break}if(u===m)throw A.i(A.d4("Invalid IPv6 host entry.",e,w))
q=t<0?u:t
A.bvK(e,w+1,q);++u
if(u!==m&&e.charCodeAt(u)!==58)throw A.i(A.d4("Invalid end of authority",e,u))}else u=w
for(;u<m;++u)if(e.charCodeAt(u)===58){p=B.d.cb(e,u+1)
k=p.length!==0?A.h1(p,n):n
break}o=B.d.af(e,w,u)}else o=n
return A.im(n,o,n,A.a(f.split("/"),x.s),k,g,d,l)}},D,H,F
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
C.tE.prototype={}
C.aFn.prototype={}
C.tD.prototype={
L(){return new C.aeL()}}
C.aeL.prototype={
U(){var w,v
this.a9()
w=this.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)$.akm().NH(0,v)},
j(){var w=$.akm(),v=w.c
if(v!=null)v.ak(0)
w.b=w.c=null
w.BM()
w.pU(D.k7)
this.a1()},
t(d){var w=null,v=this.d
return A.cY(w,w,new A.ru([D.av0,D.awo,D.awO,D.awQ][v],w),A.aus(0,w,w,v,D.a3B,w,new C.bc5(this)),w,!0,w,w)}}
C.OG.prototype={
L(){return new C.OH(A.a([],x.A))}}
C.OH.prototype={
Hm(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$Hm=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=r.c
m.toString
q=A.af(m,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.XE(q),$async$Hm)
case 7:p=e
if(r.c==null){w=1
break}m=r.w
o=J.f(m==null?null:J.A(m,"can_work"),!1)
r.p(new C.aPq(r,p))
if(o&&J.f(J.A(p,"can_work"),!0))r.j6()
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
return A.p($async$Hm,v)},
IJ(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l
var $async$IJ=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:m=!r.f
r.p(new C.aPw(r,m))
o=r.c
o.toString
q=A.af(o,!1,x.d).c
if(q==null){w=1
break}t=4
w=7
return A.h(C.XM(q,m),$async$IJ)
case 7:t=2
w=6
break
case 4:t=3
l=s.pop()
p=A.a4(l)
if(r.c==null){w=1
break}r.p(new C.aPx(r,m))
r.c.V(x.q).f.bJ(A.cZ(null,null,null,null,null,B.B,null,A.j(A.b5(p),null,null,null,null,null,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$IJ,v)},
Hl(d){return this.aAz(d)},
aAz(d){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p
var $async$Hl=A.m(function(e,f){if(e===1){t.push(f)
w=u}for(;;)switch(w){case 0:u=3
w=6
return A.h(C.XD(d),$async$Hl)
case 6:r=f
if(s.c!=null)s.p(new C.aPp(s,r))
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
return A.p($async$Hl,v)},
ob(d){return this.aCN(d)},
aCN(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$ob=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a4(r).length===0){t.c.V(x.q).f.bJ(D.IX)
w=1
break}w=3
return A.h(A.uN(C.bx1("https","www.google.com","/maps/dir/",A.J(["api","1","destination",r],x.N,x.z)).ghT(),B.m4,null),$async$ob)
case 3:if(!f&&t.c!=null)t.c.V(x.q).f.bJ(D.IW)
case 1:return A.o(u,v)}})
return A.p($async$ob,v)},
U(){var w,v,u=this
u.a9()
u.j6()
u.Hm()
u.y=A.hu(B.oS,new C.aPB(u))
w=u.c
w.toString
v=A.af(w,!1,x.d).c
if(v!=null)C.XM(v,!0).dt(new C.aPC())},
j(){var w=this.y
if(w!=null)w.ak(0)
this.a1()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d)
if(p.c==null){w=1
break}q.p(new C.aPr(q))
l=p.c
l.toString
q.Hl(l)
t=4
l=p.c
l.toString
w=7
return A.h(C.Xt(l),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.aPs(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a4(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.aPt(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.aPu(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
HM(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$HM=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(!r.f){w=1
break}o=r.c
o.toString
q=A.af(o,!1,x.d)
if(q.c==null){w=1
break}t=4
o=q.c
o.toString
w=7
return A.h(C.Xt(o),$async$HM)
case 7:p=e
if(r.c==null){w=1
break}if(J.bb(p)>r.z)r.c.V(x.q).f.bJ(A.cZ(null,null,null,B.l,B.dl,B.B,null,D.abp,null,B.af,null,null,null,B.b7,null,null,null,new A.bz(A.V(12),B.I),null,null))
r.p(new C.aPv(r,p))
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
return A.p($async$HM,v)},
FM(d){return this.anA(d)},
anA(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m,l,k,j
var $async$FM=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=r.c
k.toString
q=A.af(k,!1,x.d)
t=4
k=q.c
k.toString
n=""+d.a
w=7
return A.h(E.zv(k,"/deliveries/"+n+"/accept","Could not accept this delivery.",null),$async$FM)
case 7:p=f
$.akm().fZ(0)
if(r.c==null){w=1
break}r.p(new C.aPm(r,d))
k=r.c.V(x.q).f
m=p.ok
if(m==null)m="in My deliveries"
k.bJ(A.cZ(null,null,null,B.H,null,B.B,null,A.j("Delivery #"+n+" accepted. Your pickup code is "+m+" \u2014 give it to the restaurant when you collect.",null,null,null,null,B.b3,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
t=2
w=6
break
case 4:t=3
j=s.pop()
o=A.a4(j)
k=r.c
if(k==null){w=1
break}k.V(x.q).f.bJ(A.cZ(null,null,null,B.G,null,B.B,null,A.j(A.b5(o),null,null,null,null,B.b3,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$FM,v)},
t(d){var w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.w
if(l!=null&&J.f(J.A(l,"can_work"),!1)){if(d.d8(x.f)!=null)w=B.F
else w=A.c(d).ax.a===B.b?B.b_:B.aO
return A.cY(m,w,A.dH(!0,new C.M5(l,new C.aPz(n),m),B.W,!0),m,m,!1,m,m)}if(d.d8(x.f)!=null)w=B.F
else w=A.c(d).ax.a===B.b?B.b_:B.aO
v=A.af(d,!0,x.d).f
if(v==null)v=""
if(n.f)if(J.d7(n.d))u=m
else{u=J.bb(n.d)
t=J.bb(n.d)===1?"":"s"
t=""+u+" job"+t+" near you right now."
u=t}else u="You're offline. Go online to get delivery jobs."
u=A.J_(v,G.vU,"rider",u)
if(n.f)v=B.H.N(0.12)
else v=A.c(d).ax.a===B.b?B.as:B.ar
t=A.V(20)
if(n.f)s=B.H.N(0.5)
else s=A.c(d).ax.a===B.b?B.D:B.E
s=A.aW(s,B.n,1)
if(n.f)r=B.H
else r=A.c(d).ax.a===B.b?B.R:B.Q
r=A.ed(m,m,m,B.Z,new A.X(r,m,m,m,m,m,B.av),B.cA,m,8,m,m,8)
q=n.f
p=q?"Online":"Offline"
if(q)q=B.H
else q=A.c(d).ax.a===B.b?B.R:B.Q
o=x.p
t=A.R(A.a([D.Uj,B.aB,A.ce(m,A.ed(m,A.R(A.a([r,B.bs,A.j(p,m,m,m,m,A.t(m,m,q,m,m,m,m,m,m,m,m,13,m,m,B.a3,m,m,!0,m,m,m,m,m,m,m,m),m,m,m,m)],o),B.i,m,B.e,B.f,0,m),m,B.Z,new A.X(v,m,s,t,m,m,B.o),B.cA,m,m,m,F.lr,m),B.L,!1,D.at3,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,n.gaII(),m,m,m,m,m,m,!1,B.aa),B.ab,F.qY],o),B.i,m,B.bM,B.f,0,m)
s=n.gww()
v=n.Sb(F.jt,""+J.bb(n.d),"Available")
q=n.r
r=q==null?m:q.f
r=n.Sb(F.js,""+(r==null?0:r),"Completed today")
q=n.r
q=q==null?m:q.e
v=A.br(A.dx(A.a([v,r,n.Sb(B.hW,A.bs(q==null?0:q),"Earned today")],o),m,m,B.jk,m,B.aK,!1),80,m)
if(!n.f)r=D.U9
else if(n.e)r=B.bX
else{r=n.x
if(r.length!==0)r=new A.d2(B.ba,"Connection failed",r,"Retry",s,m)
else r=J.d7(n.d)?D.U5:A.ev(A.rT(m,new C.aPA(n),J.bb(n.d),G.vV),B.l,s)}return A.cY(m,w,A.dH(!0,A.W(A.a([u,new A.Z(G.vW,t,m),B.a2,new C.M2(s,m),v,B.a_,A.aa(r,1)],o),B.p,m,B.e,B.f,0,B.k),B.W,!0),m,m,!1,m,m)},
Sb(d,e,f){var w,v,u,t,s,r=null,q=this.c
q.toString
q=A.bO(q)
w=A.V(14)
v=this.c
v.toString
u=A.aW(A.c(v).ax.a===B.b?B.D:B.E,B.n,1)
t=A.an(d,B.l,r,r,20)
s=this.c
s.toString
v=x.p
return A.a1(r,A.R(A.a([t,B.ab,A.W(A.a([A.j(e,r,r,r,r,A.t(r,r,A.c(s).ax.a===B.b?B.t:B.r,r,r,r,r,r,r,r,r,18,r,r,B.A,r,r,!0,r,r,r,r,r,r,r,r),r,r,r,r),A.j(f,r,r,r,r,D.nc,r,r,r,r)],v),B.p,r,B.aU,B.f,0,B.k)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(q,r,u,w,r,r,B.o),r,r,r,D.Sc,D.vO,r,r,r)},
arE(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j=l.c
j.toString
j=A.bO(j)
w=A.V(16)
v=A.aW(B.l.N(0.25),B.n,1)
u=""+d.a
t=x.p
s=A.R(A.a([A.j("Order #"+u,k,k,k,k,D.ne,k,k,k,k),A.j(A.bs(d.b),k,k,k,k,D.ne.bl(B.l),k,k,k,k)],t),B.i,k,B.bM,B.f,0,k)
r=A.a1(k,D.Ye,B.j,k,k,new A.X(B.l.N(0.12),k,k,k,k,k,B.av),k,32,k,k,k,k,k,32)
q=l.c
q.toString
p=A.j("Pickup",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.b?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.aA,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
o=d.f
q=o==null?"Restaurant":o
o=l.c
o.toString
r=A.R(A.a([r,B.aB,A.aa(A.W(A.a([p,A.j(q,k,k,k,k,A.t(k,k,A.c(o).ax.a===B.b?B.t:B.r,k,k,k,k,k,k,k,k,14,k,k,B.aA,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.p,k,B.e,B.f,0,B.k),1)],t),B.i,k,B.e,B.f,0,k)
q=l.c
q.toString
p=A.a1(k,k,B.j,A.c(q).ax.a===B.b?B.D:B.E,k,k,k,20,k,k,k,k,k,2)
o=A.a1(k,D.XZ,B.j,k,k,new A.X(B.H.N(0.12),k,k,k,k,k,B.av),k,32,k,k,k,k,k,32)
n=l.c
n.toString
q=A.j("Dropoff",k,k,k,k,A.t(k,k,A.c(n).ax.a===B.b?B.R:B.Q,k,k,k,k,k,k,k,k,11,k,k,B.aA,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
if(d.gDF())n="Pinned location"
else{n=d.z
n.toString
n=B.d.a4(n)}m=l.c
m.toString
q=A.a([o,B.aB,A.aa(A.W(A.a([q,A.j(n,k,2,B.a4,k,A.t(k,k,A.c(m).ax.a===B.b?B.t:B.r,k,k,k,k,k,k,k,k,14,k,k,B.aA,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],t),B.p,k,B.e,B.f,0,B.k),1)],t)
if(d.gaci())B.c.G(q,A.a([B.ac,new A.qT(D.wL,"Directions","Directions to the drop-off",new C.aPn(l,d),new A.w("available-directions-"+u,x.O))],t))
u=A.a([new A.Z(B.b9,A.W(A.a([s,B.aw,r,new A.Z(D.SR,p,k),A.R(q,B.i,k,B.e,B.f,0,k)],t),B.p,k,B.e,B.f,0,B.k),k)],t)
if(d.cy.length!==0){s=l.c
s.toString
B.c.G(u,A.a([A.hz(A.c(s).ax.a===B.b?B.D:B.E,1,k),new A.Z(D.SX,new E.x0(d,!0,k),k)],t))}t=l.c
t.toString
u.push(A.hz(A.c(t).ax.a===B.b?B.D:B.E,1,k))
u.push(new A.Z(B.b7,A.br(A.a_4(D.Xi,k,D.anG,new C.aPo(l,d)),44,1/0),k))
return A.a1(k,A.W(u,B.i,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(j,k,v,w,k,k,B.o),k,k,k,B.fw,k,k,k,k)}}
C.RA.prototype={
L(){return new C.RB(A.a([],x.A),null,!1)}}
C.RB.prototype={
ob(d){return this.aCO(d)},
aCO(d){var w=0,v=A.q(x.H),u,t=this,s,r
var $async$ob=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=d.Q
r=s!=null&&d.as!=null?A.k(s)+","+A.k(d.as):d.z
if(r==null||B.d.a4(r).length===0){t.c.V(x.q).f.bJ(D.IX)
w=1
break}w=3
return A.h(A.uN(C.bx1("https","www.google.com","/maps/dir/",A.J(["api","1","destination",r],x.N,x.z)).ghT(),B.m4,null),$async$ob)
case 3:if(!f&&t.c!=null)t.c.V(x.q).f.bJ(D.IW)
case 1:return A.o(u,v)}})
return A.p($async$ob,v)},
U(){var w=this
w.a9()
w.j6()
w.j_(new C.b3b(w))},
wx(d){return this.aAm(d)},
j6(){return this.wx(!1)},
aAm(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j
var $async$wx=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:k=q.c
k.toString
p=A.af(k,!1,x.d)
if(p.c==null){w=1
break}k=!d
if(k)q.p(new C.b2Y(q))
t=4
m=p.c
m.toString
w=7
return A.h(A.m1(m),$async$wx)
case 7:o=f
if(q.c==null){r=[1]
w=5
break}q.p(new C.b2Z(q,o))
r.push(6)
w=5
break
case 4:t=3
j=s.pop()
n=A.a4(j)
if(q.c==null||d){r=[1]
w=5
break}q.p(new C.b3_(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null&&k)q.p(new C.b30(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$wx,v)},
Bo(d){return this.aET(d)},
aET(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$Bo=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.c
n.toString
w=3
return A.h(A.f4(null,null,!0,null,new C.b38(d),n,null,!0,x.y),$async$Bo)
case 3:if(f!==!0||r.c==null){w=1
break}t=5
n=r.c
n.toString
n=A.af(n,!1,x.d).c
n.toString
p=""+d.a
w=8
return A.h(E.zv(n,"/deliveries/"+p+"/release","Could not release this delivery.",null),$async$Bo)
case 8:if(r.c==null){w=1
break}r.p(new C.b39(r,d))
n=r.c.V(x.q).f
n.KS()
n.bJ(A.cZ(null,null,null,null,null,B.B,null,A.j("Order #"+p+" released to other riders.",null,null,null,null,null,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
t=2
w=7
break
case 5:t=4
m=s.pop()
q=A.a4(m)
n=r.c
if(n==null){w=1
break}n=n.V(x.q).f
n.KS()
n.bJ(A.cZ(null,null,null,B.G,null,B.B,null,A.j(A.b5(q),null,null,null,null,B.b3,null,null,null,null),null,B.af,null,null,null,null,null,null,null,null,null,null))
w=7
break
case 4:w=2
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Bo,v)},
G7(d){return this.aqv(d)},
aqv(d){var w=0,v=A.q(x.H),u=this,t,s
var $async$G7=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=u.c
s.toString
s=A.af(s,!1,x.d).c
s.toString
t=u.c
t.toString
w=2
return A.h(E.ak6(t,"Complete delivery",null,"Ask the customer for the 4-digit delivery code shown in their FindFood app. Hand over the food once the code is accepted.",new C.b2X(u,s,d),"Enter the customer's code"),$async$G7)
case 2:if(f&&u.c!=null)u.c.V(x.q).f.bJ(D.aeF)
return A.o(null,v)}})
return A.p($async$G7,v)},
t(d){var w,v=this,u=null
if(v.e)w=B.bX
else{w=v.f
if(w.length!==0)w=new A.d2(B.ba,"Failed to load",w,"Retry",v.gww(),u)
else w=J.d7(v.d)?D.Ua:A.ev(A.rT(u,new C.b3a(v),J.bb(v.d),G.vS),B.l,v.gww())}return A.cY(u,u,A.dH(!0,A.W(A.a([D.a84,D.ax_,A.aa(w,1)],x.p),B.p,u,B.e,B.f,0,B.k),B.W,!0),u,u,!1,u,u)},
aBd(d){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="the restaurant",i=d.c,h=i==="out_for_delivery",g=l.c
g.toString
g=A.bO(g)
w=A.V(16)
if(h)v=B.l.N(0.4)
else{v=l.c
v.toString
v=A.c(v).ax.a===B.b?B.D:B.E}v=A.aW(v,B.n,1)
u=""+d.a
t=x.p
s=A.a([A.aa(A.j("Order #"+u,k,k,k,k,D.ne,k,k,k,k),1)],t)
if(i!=="cancelled"){r=d.f
if(r==null)r=j
B.c.G(s,A.a([E.brl(new A.w("rider-chat-"+u,x.O),new C.b31(l,d),"the customer or "+r),B.ac],t))}s.push(new A.D0(i,k))
s=A.a([A.R(s,B.i,k,B.e,B.f,0,k),B.aG,A.j(A.bs(d.b),k,k,k,k,D.kn.bl(B.l),k,k,k,k)],t)
r=d.z
if(r!=null||d.Q!=null){if(d.gDF())r="Pinned location"
else{r.toString
r=B.d.a4(r)}r=A.a([A.j(r,k,2,B.a4,k,D.kn,k,k,k,k)],t)
if(d.gDF()){q=l.c
q.toString
r.push(A.j("Shared from the customer's phone",k,k,k,k,A.t(k,k,A.c(q).ax.a===B.b?B.v:B.u,k,k,k,k,k,k,k,k,12,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}r=A.a([D.XO,B.ac,A.aa(A.W(r,B.p,k,B.e,B.f,0,B.k),1)],t)
if(d.gaci())B.c.G(r,A.a([B.ac,new A.qT(D.wL,"Directions","Directions to the drop-off",new C.b32(l,d),new A.w("rider-directions-"+u,x.O))],t))
B.c.G(s,A.a([B.N,A.R(r,B.i,k,B.e,B.f,0,k)],t))}if(d.ch!=null)r=i==="pending"||i==="preparing"||i==="ready"
else r=!1
if(r&&d.ok!=null){r=x.O
q=d.ok
q.toString
p=d.f
if(p==null)p=j
i=i==="ready"?"The food is ready.":"The kitchen is still preparing it."
o=l.c
o.toString
n=A.j("In the bag",k,k,k,k,A.t(k,k,A.c(o).ax.a===B.b?B.v:B.u,k,k,k,k,k,k,k,k,13,k,k,B.a3,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)
m=l.c
m.toString
o=A.c(m).ax.a===B.b?B.t:B.r
m=l.c
m.toString
m=A.c(m).ax.a===B.b?B.D:B.E
B.c.G(s,A.a([B.aw,new A.J1("Pickup code",q,"Check the bag is labelled #"+u+" and has everything below, then give this code to "+p+". "+i,B.dg,new A.w("rider-pickup-code-"+u,r)),B.N,n,B.aG,new E.x0(d,!1,k),B.a2,A.br(A.kG(D.YG,new A.w("rider-release-"+u,r),D.alj,new C.b33(l,d),A.lt(k,k,k,k,k,k,k,k,k,o,k,k,k,k,new A.bz(A.V(12),B.I),new A.au(m,1,B.n,-1),k,k,B.Ju,k)),46,1/0)],t))}if(h)B.c.G(s,A.a([B.aw,A.br(A.a_4(D.Yo,new A.w("rider-complete-"+u,x.O),D.alF,new C.b34(l,d)),46,1/0)],t))
return A.a1(k,A.W(s,B.p,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(g,k,v,w,k,k,B.o),k,k,k,B.fw,B.b9,k,k,k)}}
C.TC.prototype={
L(){return new C.TD()}}
C.TD.prototype={
U(){this.a9()
this.j6()},
j6(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$j6=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:l=q.c
l.toString
p=A.af(l,!1,x.d).c
if(p==null){w=1
break}q.p(new C.bcd(q))
t=4
w=7
return A.h(C.XD(p),$async$j6)
case 7:o=e
if(q.c==null){r=[1]
w=5
break}q.p(new C.bce(q,o))
r.push(6)
w=5
break
case 4:t=3
k=s.pop()
n=A.a4(k)
if(q.c==null){r=[1]
w=5
break}q.p(new C.bcf(q,n))
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bcg(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$j6,v)},
t(d){var w,v,u,t,s,r,q=this,p=null,o=q.d,n=q.gww(),m=x.p,l=A.a([D.amA,B.b2,D.abj],m)
if(q.f&&o==null)l.push(D.a88)
else{w=q.e
if(w!=null&&o==null)l.push(A.W(A.a([A.j(w,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.b?B.v:B.u,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),A.c1(B.e4,p,p,p,n,p,p)],m),B.i,p,B.e,B.f,0,B.k))
else if(o!=null){w=A.V(16)
v=A.aW(B.l.N(0.3),B.n,1)
u=A.bs(o.e)
u=A.j(u,D.auu,p,p,p,A.t(p,p,A.c(d).ax.a===B.b?B.l:B.ap,p,p,p,p,p,p,p,p,36,p,p,B.A,p,p,!0,p,-1,p,p,p,p,p,p),p,p,p,p)
t=A.an(D.VA,A.c(d).ax.a===B.b?B.v:B.u,p,p,14)
s=o.f
r=s===1?"y":"ies"
w=A.a1(p,A.W(A.a([D.alc,B.aG,u,B.ae,A.R(A.a([t,B.bs,A.j(""+s+" deliver"+r+" completed today",p,p,p,p,D.nc.bl(A.c(d).ax.a===B.b?B.v:B.u),p,p,p,p)],m),B.i,p,B.e,B.f,0,p)],m),B.p,p,B.e,B.f,0,B.k),B.j,p,p,new A.X(B.hE,p,v,w,p,p,B.o),p,p,p,p,B.dc,p,p,1/0)
v=A.R(A.a([q.I9("This week",A.bs(o.r)),B.dE,q.I9("This month",A.bs(o.w))],m),B.i,p,B.e,B.f,0,p)
u=q.I9("All time",A.bs(o.c))
t=o.x
m=A.a([w,B.aw,v,B.aw,A.R(A.a([u,B.dE,q.I9("Rating",t==null?"No ratings yet":"\u2605 "+B.h.ai(t,1))],m),B.i,p,B.e,B.f,0,p),B.aJ,D.amE,B.aw],m)
w=o.y
if(w.length===0)m.push(A.j("Completed deliveries will appear here.",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.b?B.R:B.Q,p,p,p,p,p,p,p,p,p,p,p,p,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p))
else B.c.G(m,new A.ax(w,q.gaEA(),A.ao(w).i("ax<1,d>")))
B.c.G(l,m)}}return A.cY(p,p,A.dH(!0,A.ev(A.dx(l,p,p,B.az,p,B.V,!1),B.l,n),B.W,!0),p,p,!1,p,p)},
I9(d,e){var w,v,u,t=null,s=this.c
s.toString
s=A.bO(s)
w=A.V(14)
v=this.c
v.toString
u=A.aW(A.c(v).ax.a===B.b?B.D:B.E,B.n,1)
return A.aa(A.a1(t,A.W(A.a([A.j(d,t,t,t,t,D.nc,t,t,t,t),B.aD,A.j(e,t,t,t,t,D.ne,t,t,t,t)],x.p),B.p,t,B.e,B.f,0,B.k),B.j,t,t,new A.X(s,t,u,w,t,t,B.o),t,t,t,t,B.b9,t,t,t),1)},
aEB(d){var w,v,u,t,s,r=null,q=d.e,p=A.a([],x.s),o=d.b
if(o!=null)p.push(o)
if(q!=null)p.push(""+A.ch(q)+"/"+A.bI(q)+" "+B.d.d6(B.m.k(A.kJ(q)),2,"0")+":"+B.d.d6(B.m.k(A.lv(q)),2,"0"))
w=B.c.b9(p," \xb7 ")
p=this.c
p.toString
p=A.bO(p)
o=A.V(12)
v=this.c
v.toString
u=A.aW(A.c(v).ax.a===B.b?B.D:B.E,B.n,1)
t=A.j("Order #"+d.a,r,r,r,r,D.kn,r,r,r,r)
s=this.c
s.toString
v=x.p
return A.a1(r,A.R(A.a([A.aa(A.W(A.a([t,A.j(w,r,r,r,r,D.nc.bl(A.c(s).ax.a===B.b?B.R:B.Q),r,r,r,r)],v),B.p,r,B.e,B.f,0,B.k),1),A.j(A.bs(d.d),r,r,r,r,D.kn.U1(B.l,B.z),r,r,r,r)],v),B.i,r,B.e,B.f,0,r),B.j,r,r,new A.X(p,r,u,o,r,r,B.o),r,r,r,B.bR,D.vO,r,r,r)}}
C.aeP.prototype={
t(d){var w=null,v=x.p
return A.cY(w,w,A.dH(!0,A.dx(A.a([D.an8,B.aJ,D.L8,B.dF,new A.uW("rider",A.a([new A.jc(K.pT,"Payout account","Where your delivery pay is sent",new C.bcS(d),w,D.aus)],v),w),B.aJ,K.ru],v),w,w,B.az,w,B.V,!1),B.W,!0),w,w,!1,w,w)}}
C.afz.prototype={
t(d){var w=$.akm()
return new A.mi(new C.beh(w),null,w,null)}}
C.aiv.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a1()}}
C.MF.prototype={
K(){return"SharingState."+this.b}}
C.M1.prototype={
NH(d,e){var w,v=this
v.b=e
w=v.c
if(w!=null)w.ak(0)
v.c=A.hu(B.vx,new C.aFv(v))
v.fZ(0)},
fZ(d){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n,m
var $async$fZ=A.m(function(e,f){if(e===1){s.push(f)
w=t}for(;;)switch(w){case 0:n=r.b
if(n==null){w=1
break}t=4
w=7
return A.h(A.m1(n),$async$fZ)
case 7:q=f
p=J.bqI(q,new C.aFu())
w=p?8:10
break
case 8:w=11
return A.h(r.wJ(),$async$fZ)
case 11:w=9
break
case 10:r.BM()
r.pU(D.k7)
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
Mr(){var w=0,v=A.q(x.H),u=this
var $async$Mr=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:u.BM()
w=2
return A.h(u.fZ(0),$async$Mr)
case 2:return A.o(null,v)}})
return A.p($async$Mr,v)},
wJ(){var w=0,v=A.q(x.H),u,t=2,s=[],r=this,q,p,o,n
var $async$wJ=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:if(r.e!=null){w=1
break}t=4
w=7
return A.h($.n0().y5(),$async$wJ)
case 7:if(!e){p=r.pU(D.mW)
u=p
w=1
break}w=8
return A.h($.n0().n9(),$async$wJ)
case 8:q=e
w=q===B.ew?9:10
break
case 9:w=11
return A.h($.n0().nB(0),$async$wJ)
case 11:q=e
case 10:if(q===B.ew||q===B.i5){p=r.pU(D.mW)
u=p
w=1
break}r.e=$.n0().XK(D.a47).aSd(r.gaB8(),new C.aFs(r))
p=r.d
if(p!=null)p.ak(0)
r.d=A.hu(B.oR,new C.aFt(r))
r.pU(D.Ih)
t=2
w=6
break
case 4:t=3
n=s.pop()
r.pU(D.mW)
w=6
break
case 3:w=2
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$wJ,v)},
aB9(d){this.f=d
this.aFt(d)},
Bv(d,e){return this.aGw(d,e)},
aFt(d){return this.Bv(d,!1)},
aGw(d,e){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k
var $async$Bv=A.m(function(f,g){if(f===1){s.push(g)
w=t}for(;;)switch(w){case 0:l=q.b
if(l==null||q.w){w=1
break}o=new A.cn(Date.now(),0,!1)
if(!e){n=q.r
n=n!=null&&o.e5(n).a<6e6}else n=!1
if(n){w=1
break}q.w=!0
q.r=o
t=4
n=d.r
n=n>=0&&n<=360?n:null
w=7
return A.h(C.and(l,n,d.a,d.b),$async$Bv)
case 7:p=g
if(!p){q.BM()
q.pU(D.k7)}r.push(6)
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
return A.p($async$Bv,v)},
BM(){var w=this,v=w.e
if(v!=null)v.ak(0)
w.e=null
v=w.d
if(v!=null)v.ak(0)
w.f=w.d=null},
pU(d){if(this.a===d)return
this.a=d
this.T()}}
C.M2.prototype={
L(){return new C.TE(B.ev,null,!1)}}
C.TE.prototype={
U(){var w=this
w.a9()
w.jA()
w.j_(w.gFU())},
b7(){var w,v,u=this
u.cl()
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
return A.h(C.alV(q),$async$jA)
case 7:p=e
if(r.c!=null)r.p(new C.bcm(r,p))
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
vC(d,e){return this.aod(d,e)},
aod(d,e){var w=0,v=A.q(x.H),u=1,t=[],s=[],r=this,q,p,o,n,m,l,k
var $async$vC=A.m(function(f,g){if(f===1){t.push(g)
w=u}for(;;)switch(w){case 0:m=J.a6(d)
l=A.bw(m.h(d,"id"))
r.p(new C.bck(r,l))
o=r.c
o.toString
o=A.af(o,!1,x.d).c
o.toString
q=o
u=3
w=e?6:8
break
case 6:w=9
return A.h(C.all(q,l),$async$vC)
case 9:o=r.c
if(o!=null)A.b0(o,"Order #"+A.k(m.h(d,"order_id"))+" is yours. Find it in My Deliveries for your pickup code.",!1)
r.a.c.$0()
w=7
break
case 8:w=10
return A.h(C.alA(q,l),$async$vC)
case 10:case 7:s.push(5)
w=4
break
case 3:u=2
k=t.pop()
p=A.a4(k)
m=r.c
if(m!=null)A.b0(m,A.b5(p),!0)
s.push(5)
w=4
break
case 2:s=[1]
case 4:u=1
if(r.c!=null)r.p(new C.bcl(r))
w=11
return A.h(r.jA(),$async$vC)
case 11:w=s.pop()
break
case 5:return A.o(null,v)
case 1:return A.n(t.at(-1),v)}})
return A.p($async$vC,v)},
t(d){var w,v,u,t,s,r,q=this,p=null
if(J.d7(q.d))return B.aI
w=A.a([A.j("Requests for you",p,p,p,p,A.t(p,p,A.c(d).ax.a===B.b?B.t:B.r,p,p,p,p,p,p,p,p,17,p,p,B.A,p,p,!0,p,p,p,p,p,p,p,p),p,p,p,p),B.a_],x.p)
for(v=J.bv(q.d),u=q.gFU();v.A();){t=v.gO(v)
s=q.e
r=J.A(t,"id")
w.push(new C.ac3(t,s==null?r==null:s===r,new C.bcn(q,t),u,p))}return new A.Z(D.vT,A.W(w,B.p,D.ar7,B.e,B.f,0,B.k),p)}}
C.ac3.prototype={
t(a1){var w,v,u,t,s,r,q,p,o,n,m,l=this,k=null,j="total_amount",i="restaurant_address",h=A.c(a1).ax.a===B.b?B.t:B.r,g=A.c(a1).ax.a===B.b?B.v:B.u,f=Date.now(),e=l.c,d=J.a6(e),a0=A.ck(d.h(e,"seconds_left"))
a0=a0==null?k:B.h.b6(a0)
w=new A.cn(f,0,!1).pv(A.eM(0,0,a0==null?0:a0).a)
f=x.g.a(d.h(e,"items"))
if(f==null)f=B.bd
v=J.eo(f,new C.b3K(),x.N).b9(0,", ")
f=A.k(d.h(e,"id"))
a0=x.O
u=A.bO(a1)
t=A.V(18)
s=A.aW(B.l,B.n,1.5)
r=A.a([new A.d9(0,B.bC,B.l.N(0.18),B.qZ,16)],x.V)
q=d.h(e,"restaurant_name")
p=x.p
q=A.a([D.YE,B.ac,A.aa(A.j(A.k(q==null?"A restaurant":q)+" asked you",k,k,k,k,A.t(k,k,h,k,k,k,k,k,k,k,k,15,k,k,B.A,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k),1)],p)
if(A.fM(d.h(e,j))){o=A.bs(A.bw(d.h(e,j)))
q.push(A.j(o,k,k,k,k,A.t(k,k,A.c(a1).ax.a===B.b?B.l:B.ap,k,k,k,k,k,k,k,k,k,k,k,B.A,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))}q=A.R(q,B.i,k,B.e,B.f,0,k)
o=A.k(d.h(e,"order_id"))
n=v.length===0?"":" \xb7 "+v
n=A.a([q,B.aG,A.j("Order #"+o+n,k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k)],p)
if(d.h(e,i)!=null)n.push(A.j("Pick up: "+A.k(d.h(e,i)),k,k,k,k,A.t(k,k,g,k,k,k,k,k,k,k,k,13,k,k,k,k,k,!0,k,k,k,k,k,k,k,k),k,k,k,k))
n.push(B.N)
n.push(new E.A9(w,new C.b3L(l,g),k))
n.push(B.N)
q=A.k(d.h(e,"id"))
o=l.d
m=o?k:new C.b3M(l)
m=A.aa(A.t8(D.amr,new A.w("rider-offer-decline-"+q,a0),m,k),1)
e=A.k(d.h(e,"id"))
d=o?k:new C.b3N(l)
n.push(A.R(A.a([m,B.ab,A.aa(new A.cF("Accept delivery",d,o,k,new A.w("rider-offer-accept-"+e,a0)),2)],p),B.i,k,B.e,B.f,0,k))
return A.a1(k,A.W(n,B.p,k,B.e,B.f,0,B.k),B.j,k,k,new A.X(u,k,s,t,r,k,B.o),k,k,new A.w("rider-offer-card-"+f,a0),B.bR,B.b9,k,k,k)}}
C.aj4.prototype={
j(){var w=this.dO$
if(w!=null)w.ak(0)
this.a1()}}
C.M4.prototype={
L(){return new C.TF()}}
C.TF.prototype={
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
return A.h(E.Xy(q),$async$h5)
case 7:p=e
if(r.c!=null)r.p(new C.bcr(r,p))
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
zL(){var w=0,v=A.q(x.H),u=this,t
var $async$zL=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:t=u.c
t.toString
w=4
return A.h(A.dL(t,new E.qC(!0,null),x.P),$async$zL)
case 4:w=e!=null?2:3
break
case 2:w=5
return A.h(u.h5(),$async$zL)
case 5:case 3:return A.o(null,v)}})
return A.p($async$zL,v)},
t(a5){var w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,a0="status",a1="paid",a2="failed",a3="order_count",a4=this.d
if(a4==null)return B.aI
w=A.c(a5).ax.a===B.b?B.t:B.r
v=A.c(a5).ax.a===B.b?B.v:B.u
u=J.a6(a4)
t=J.f(u.h(a4,"payout_mode"),"automatic")
s=E.ak5(a4)
r=x.g.a(u.h(a4,"payouts"))
if(r==null)r=B.bd
q=J.e_(r,x.P)
r=A.bO(a5)
p=A.V(18)
o=A.aW(A.c(a5).ax.a===B.b?B.D:B.E,B.n,1)
n=A.j("Waiting to be paid",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
m=A.ck(u.h(a4,"owed"))
m=m==null?d:B.h.b6(m)
l=x.p
m=A.aa(A.W(A.a([n,A.j(A.bs(m==null?0:m),D.aqA,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,22,d,d,B.dy,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.p,d,B.e,B.f,0,B.k),1)
n=A.j("Paid to you",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)
k=A.ck(u.h(a4,"paid_total"))
k=k==null?d:B.h.b6(k)
n=A.R(A.a([m,A.aa(A.W(A.a([n,A.j(A.bs(k==null?0:k),d,d,d,d,D.aiv,d,d,d,d)],l),B.p,d,B.e,B.f,0,B.k),1)],l),B.i,d,B.e,B.f,0,d)
u=A.ck(u.h(a4,"rider_share_percent"))
u=H.hw(u==null?100:u)
m=t?"after each delivery":"weekly"
m=A.a([n,B.ae,A.j("You earn "+u+" of each delivery fee, paid "+m+".",d,d,d,d,A.t(d,d,v,d,d,d,d,d,d,d,d,12.5,d,d,d,d,1.4,!0,d,d,d,d,d,d,d,d),d,d,d,d),B.N],l)
u=this.ganN()
if(s==null)m.push(A.br(A.Iu(G.xq,D.apH,D.anE,u,d),d,1/0))
else{n=A.V(10)
k=A.aa(A.j("Paid to "+s,d,d,d,d,A.t(d,d,w,d,d,d,d,d,d,d,d,13.5,d,d,B.a3,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d),1)
m.push(A.dl(!1,n,!0,A.R(A.a([D.Yt,B.ac,k,A.j("Change",d,d,d,d,A.t(d,d,A.c(a5).ax.a===B.b?B.l:B.ap,d,d,d,d,d,d,d,d,13,d,d,d,d,d,!0,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d,!0,d,d,d,d,d,d,d,d,d,d,d,u,d,d,d,d,d,d,d))}if(!q.gae(q)){u=A.a([A.hz(A.c(a5).ax.a===B.b?B.D:B.E,24,d)],l)
for(n=A.hc(q,0,A.kX(3,"count",x.S),q.$ti.i("ai.E")),k=n.$ti,n=new A.b3(n,n.gC(0),k.i("b3<aL.E>")),k=k.i("aL.E");n.A();){j=n.d
if(j==null)j=k.a(j)
i=J.a6(j)
if(J.f(i.h(j,a0),a1))h=B.cC
else h=J.f(i.h(j,a0),a2)?B.lR:B.i1
if(J.f(i.h(j,a0),a1))g=B.H
else g=J.f(i.h(j,a0),a2)?B.G:B.ad
g=A.an(h,g,d,d,16)
h=A.bs(B.h.b6(A.bK(i.h(j,"amount"))))
f=A.k(i.h(j,a3))
e=J.f(i.h(j,a3),1)?"y":"ies"
h=A.j(h+" \xb7 "+f+" deliver"+e,d,d,d,d,new A.x(!0,w,d,d,d,d,13,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)
if(J.f(i.h(j,a0),a1))j=H.boX(i.h(j,"paid_at"))
else j=J.f(i.h(j,a0),a2)?"Failed":"Sending\u2026"
u.push(new A.Z(F.oW,A.R(A.a([g,B.ac,new A.dq(1,B.b1,h,d),A.j(j,d,d,d,d,new A.x(!0,v,d,d,d,d,12,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d),d,d,d,d)],l),B.i,d,B.e,B.f,0,d),d))}B.c.G(m,u)}return A.a1(d,A.W(m,B.p,d,B.e,B.f,0,B.k),B.j,d,d,new A.X(r,d,o,p,d,d,B.o),d,d,D.asI,B.vE,B.dx,d,d,1/0)}}
C.M5.prototype={
L(){var w=$.ab()
return new C.TL(new A.bu(B.a6,w),new A.bu(B.a6,w),new A.bu(B.a6,w),new A.bu(B.a6,w),new A.bu(B.a6,w))},
hf(d){return this.d.$1(d)}}
C.TL.prototype={
U(){var w,v,u,t=this
t.a9()
w=t.a.c
v=J.a6(w)
u=v.h(w,"ghana_card")
t.d.sc1(0,A.k(u==null?"":u))
u=v.h(w,"licence_number")
t.e.sc1(0,A.k(u==null?"":u))
u=v.h(w,"plate")
t.f.sc1(0,A.k(u==null?"":u))
u=v.h(w,"emergency_name")
t.r.sc1(0,A.k(u==null?"":u))
u=v.h(w,"emergency_phone")
t.w.sc1(0,A.k(u==null?"":u))
v=v.h(w,"vehicle")
t.x=A.k(v==null?"motorbike":v)},
j(){var w,v,u,t=this
for(w=[t.d,t.e,t.f,t.r,t.w],v=0;v<5;++v){u=w[v]
u.R8$=$.ab()
u.p4$=0}t.a1()},
Bk(){var w=0,v=A.q(x.H),u=1,t=[],s=this,r,q,p,o
var $async$Bk=A.m(function(d,e){if(d===1){t.push(e)
w=u}for(;;)switch(w){case 0:u=3
q=s.c
q.toString
q=A.af(q,!1,x.d).c
q.toString
w=6
return A.h(C.XE(q),$async$Bk)
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
return A.p($async$Bk,v)},
Ia(){var w=0,v=A.q(x.H),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g,f
var $async$Ia=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.x
g=h==="motorbike"||h==="car"
h=A.cG("^GHA-?\\d{9}-?\\d$",!1,!1)
n=q.d
m=B.d.a4(n.a.a)
if(!h.b.test(m)){h=q.c
h.toString
A.b0(h,"Enter your Ghana Card number, e.g. GHA-123456789-0.",!0)
w=1
break}if(g)h=B.d.a4(q.e.a.a).length<4||B.d.a4(q.f.a.a).length<4
else h=!1
if(h){h=q.c
h.toString
A.b0(h,"Add your licence number and number plate.",!0)
w=1
break}h=q.r
if(B.d.a4(h.a.a).length<2||B.d.a4(q.w.a.a).length<9){h=q.c
h.toString
A.b0(h,"Add someone we can call in an emergency.",!0)
w=1
break}q.p(new C.bcT(q))
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
return A.h(C.an7(m,A.J(["ghana_card",n,"vehicle",l,"licence_number",k,"plate",j,"emergency_name",B.d.a4(h.a.a),"emergency_phone",B.d.a4(q.w.a.a)],x.N,x.z)),$async$Ia)
case 7:p=e
q.a.hf(p)
h=q.c
if(h!=null)A.b0(h,"Sent! We'll let you know once you're approved.",!1)
r.push(6)
w=5
break
case 4:t=3
f=s.pop()
o=A.a4(f)
h=q.c
if(h!=null)A.b0(h,A.b5(o),!0)
r.push(6)
w=5
break
case 3:r=[2]
case 5:t=2
if(q.c!=null)q.p(new C.bcU(q))
w=r.pop()
break
case 6:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$Ia,v)},
t(d){var w,v,u,t,s,r,q,p,o,n,m,l,k,j=this,i=null,h=j.a.c,g=J.a6(h),f=A.k(g.h(h,"status")),e=x.g.a(g.h(h,"missing"))
if(e==null)e=B.bd
w=J.eo(e,new C.bcW(),x.N).il(0)
v=A.af(d,!0,x.d)
u=A.c(d).ax.a===B.b?B.t:B.r
t=A.c(d).ax.a===B.b?B.v:B.u
s=new C.bcZ(d,t,u)
e=v.f
if(e==null)e=""
r=f==="pending"
e=A.J_(e,B.p2,"rider",r?"We're checking your details.":"Let's get you verified so you can start earning.")
q=x.p
p=A.a([],q)
if(r)p.push(new C.DR(B.fr,B.lS,"Thanks! Your details are with FindFood","We may call you to meet and see your Ghana Card"+(J.f(g.h(h,"vehicle"),"motorbike")||J.f(g.h(h,"vehicle"),"car")?" and licence":"")+". You'll get a notification as soon as you're approved.",D.atP))
else{r=A.a([],q)
o=f==="rejected"
if(o){g=g.h(h,"rejection_reason")
r.push(new C.DR(B.G,D.Wh,"We couldn't approve you yet",A.k(g==null?"Please check your details.":g)+". Fix it below and send again.",D.atW))}else r.push(D.av4)
r.push(B.a2)
r.push(s.$4(1,"A clear photo of your face",!w.m(0,"photo"),D.U_))
r.push(s.$4(2,"Your phone number",!w.m(0,"phone"),A.c1(D.anL,D.aqL,i,i,new C.bcX(j,d),i,i)))
r.push(s.$4(3,"Your ID and vehicle",!1,i))
r.push(B.aG)
r.push(A.cU(j.d,"Ghana Card number (GHA-123456789-0)",D.arb,i,1,!1,i,D.Vl,i,i,i))
r.push(B.N)
r.push(A.j("How do you deliver?",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a_)
g=A.a([],q)
for(n=D.Dg.gha(D.Dg),n=n.gal(n),m=x.O;n.A();){l=n.gO(n)
k=l.a
g.push(A.r6(i,i,new A.w("vehicle-"+k,m),A.j(l.b,i,i,i,i,i,i,i,i,i),i,new C.bcY(j,l),j.x===k,i,i,i,i))}r.push(A.fr(B.bm,g,B.bA,8,8))
g=j.x
if(g==="motorbike"||g==="car")B.c.G(r,A.a([B.N,A.cU(j.e,"Driver's licence number",D.apN,i,1,!1,i,B.wY,i,i,i),B.ae,A.cU(j.f,"Number plate, e.g. GR 1234-24",D.ar3,i,1,!1,i,B.lM,i,i,i)],q))
r.push(B.a2)
r.push(A.j("Emergency contact",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,i,i,i,B.z,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a_)
r.push(A.cU(j.r,"Their name",D.arG,i,1,!1,i,B.dU,i,i,i))
r.push(B.ae)
r.push(A.cU(j.w,"Their phone number",D.atx,B.iw,1,!1,i,B.lL,i,i,i))
r.push(B.a_)
r.push(A.j("Only FindFood admins see these details. We never share your Ghana Card number.",i,i,i,i,A.t(i,i,t,i,i,i,i,i,i,i,i,12,i,i,i,i,1.4,!0,i,i,i,i,i,i,i,i),i,i,i,i))
r.push(B.a2)
g=o?"Send again":"Send for approval"
o=j.y
r.push(new A.cF(g,o||w.a!==0?i:j.gaFv(),o,i,D.asf))
if(w.a!==0)r.push(new A.Z(B.jh,A.j("Add your photo and phone number first (steps 1 and 2).",i,i,i,i,A.t(i,i,A.c(d).ax.a===B.b?B.l:B.ap,i,i,i,i,i,i,i,i,12.5,i,i,i,i,i,!0,i,i,i,i,i,i,i,i),i,i,i,i),i))
B.c.G(p,r)}return A.ev(A.dx(A.a([e,new A.Z(B.jk,A.W(p,B.p,i,B.e,B.f,0,B.k),i)],q),i,i,D.Sa,i,B.V,!1),B.l,j.gaEK())}}
C.DR.prototype={
t(d){var w,v,u=this,t=null,s=u.c,r=s.N(0.1),q=A.V(14),p=A.aW(s.N(0.35),B.n,1)
s=A.an(u.d,s,t,t,22)
w=A.j(u.e,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.b?B.t:B.r,t,t,t,t,t,t,t,t,t,t,t,B.A,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)
v=x.p
return A.a1(t,A.R(A.a([s,B.ab,A.aa(A.W(A.a([w,B.h5,A.j(u.f,t,t,t,t,A.t(t,t,A.c(d).ax.a===B.b?B.v:B.u,t,t,t,t,t,t,t,t,13,t,t,t,t,1.4,!0,t,t,t,t,t,t,t,t),t,t,t,t)],v),B.p,t,B.e,B.f,0,B.k),1)],v),B.p,t,B.e,B.f,0,t),B.j,t,t,new A.X(r,t,p,q,t,t,B.o),t,t,t,t,B.b8,t,t,1/0)}}
var z=a.updateTypes(["ap<~>()","tE(@)","ap<~>({silent:M})","d(tE)","~(jS)"])
C.aFo.prototype={
$1(d){var w,v,u,t,s="completed_at"
x.P.a(d)
w=J.a6(d)
v=w.h(d,"order_id")
u=w.h(d,"restaurant_name")
w.h(d,"delivery_address")
t=w.h(d,"earning")
if(t==null)t=0
if(w.h(d,s)==null)w=null
else{w=A.iQ(J.bM(w.h(d,s)))
w=w==null?null:w.hF()}return new C.tE(v,u,t,w)},
$S:z+1}
C.bc5.prototype={
$1(d){var w=this.a
return w.p(new C.bc4(w,d))},
$S:10}
C.bc4.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.aPq.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aPw.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.aPx.prototype={
$0(){return this.a.f=!this.b},
$S:0}
C.aPp.prototype={
$0(){return this.a.r=C.buM(this.b)},
$S:0}
C.aPB.prototype={
$1(d){return this.a.HM()},
$S:28}
C.aPC.prototype={
$1(d){},
$S:13}
C.aPr.prototype={
$0(){var w=this.a
w.e=!0
w.x=""},
$S:0}
C.aPs.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.bb(v)},
$S:0}
C.aPt.prototype={
$0(){return this.a.x=A.b5(this.b)},
$S:0}
C.aPu.prototype={
$0(){return this.a.e=!1},
$S:0}
C.aPv.prototype={
$0(){var w=this.a,v=this.b
w.d=v
w.z=J.bb(v)},
$S:0}
C.aPm.prototype={
$0(){return J.zj(this.a.d,new C.aPl(this.b))},
$S:0}
C.aPl.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.aPz.prototype={
$1(d){var w=this.a
return w.p(new C.aPy(w,d))},
$S:46}
C.aPy.prototype={
$0(){return this.a.w=this.b},
$S:0}
C.aPA.prototype={
$2(d,e){var w=this.a
return w.arE(J.A(w.d,e))},
$S:100}
C.aPn.prototype={
$0(){return this.a.ob(this.b)},
$S:0}
C.aPo.prototype={
$0(){return this.a.FM(this.b)},
$S:0}
C.b3b.prototype={
$0(){return this.a.wx(!0)},
$S:2}
C.b2Y.prototype={
$0(){var w=this.a
w.e=!0
w.f=""},
$S:0}
C.b2Z.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.b3_.prototype={
$0(){return this.a.f=A.b5(this.b)},
$S:0}
C.b30.prototype={
$0(){return this.a.e=!1},
$S:0}
C.b38.prototype={
$1(d){var w=null,v=A.j("Release order #"+this.a.a+"?",w,w,w,w,w,w,w,w,w)
return A.fy(A.a([A.c1(D.ano,w,w,w,new C.b36(d),w,w),A.c1(D.anu,D.asy,w,w,new C.b37(d),w,w)],x.p),w,D.alr,!1,w,v)},
$S:16}
C.b36.prototype={
$0(){A.aZ(this.a,!1).aV(!1)
return null},
$S:0}
C.b37.prototype={
$0(){A.aZ(this.a,!1).aV(!0)
return null},
$S:0}
C.b39.prototype={
$0(){return J.zj(this.a.d,new C.b35(this.b))},
$S:0}
C.b35.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b2X.prototype={
$1(d){return this.afF(d)},
afF(d){var w=0,v=A.q(x.H),u,t=this,s,r,q
var $async$$1=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:s=t.c
w=3
return A.h(E.zv(t.b,"/orders/"+s.a+"/deliver","Could not complete this delivery.",d),$async$$1)
case 3:r=f
q=t.a
if(q.c==null){w=1
break}q.p(new C.b2W(q,s,r))
case 1:return A.o(u,v)}})
return A.p($async$$1,v)},
$S:58}
C.b2W.prototype={
$0(){var w=this.a,v=J.X7(w.d,new C.b2V(this.b))
if(v!==-1)J.eK(w.d,v,this.c)},
$S:0}
C.b2V.prototype={
$1(d){return d.a===this.a.a},
$S:23}
C.b3a.prototype={
$2(d,e){var w=this.a
return w.aBd(J.A(w.d,e))},
$S:100}
C.b31.prototype={
$0(){var w,v,u=this.a.c
u.toString
w=this.b
v=w.f
return A.FX(u,w.a,A.a([D.Ox,new A.l8("restaurant",v==null?"Restaurant":v,"Collecting the order")],x.J))},
$S:0}
C.b32.prototype={
$0(){return this.a.ob(this.b)},
$S:0}
C.b33.prototype={
$0(){return this.a.Bo(this.b)},
$S:0}
C.b34.prototype={
$0(){return this.a.G7(this.b)},
$S:0}
C.bcd.prototype={
$0(){var w=this.a
w.f=!0
w.e=null},
$S:0}
C.bce.prototype={
$0(){return this.a.d=C.buM(this.b)},
$S:0}
C.bcf.prototype={
$0(){return this.a.e=A.b5(this.b)},
$S:0}
C.bcg.prototype={
$0(){return this.a.f=!1},
$S:0}
C.bcS.prototype={
$0(){return A.dL(this.a,new E.qC(!0,null),x.P)},
$S:0}
C.beh.prototype={
$2(d,e){var w,v,u,t,s,r,q,p=null,o=this.a,n=o.a
if(n===D.k7)return B.aI
w=n===D.Ih
v=w?B.H:B.ad
u=v.N(0.1)
t=A.V(14)
s=A.aW(v.N(0.35),B.n,1)
r=A.an(w?B.q7:D.Wk,v,p,p,20)
q=w?"The customer can see you on the map. Keep FindFood open while you deliver.":"Turn on location so the customer can see you coming."
r=A.a([r,B.ab,A.aa(A.j(q,p,p,p,p,A.t(p,p,A.c(d).ax.a===B.b?B.t:B.r,p,p,p,p,p,p,p,p,13,p,p,B.a3,p,1.35,!0,p,p,p,p,p,p,p,p),p,p,p,p),1)],x.p)
if(!w)r.push(A.c1(D.an6,D.ark,p,p,o.gaVD(),p,p))
return A.a1(p,A.R(r,B.i,p,B.e,B.f,0,p),B.j,p,p,new A.X(u,p,s,t,p,p,B.o),p,p,D.arL,D.vT,D.SK,p,p,p)},
$S:47}
C.alS.prototype={
$1(d){return A.BK(d)},
$S:200}
C.aFv.prototype={
$1(d){return this.a.fZ(0)},
$S:28}
C.aFu.prototype={
$1(d){return d.ch!=null&&d.r==="delivery"&&B.c.m(F.xU,d.c)},
$S:23}
C.aFs.prototype={
$1(d){var w=this.a
w.BM()
w.pU(D.mW)},
$S:13}
C.aFt.prototype={
$1(d){var w=this.a,v=w.f
if(v!=null)w.Bv(v,!0)},
$S:28}
C.bcm.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bck.prototype={
$0(){return this.a.e=this.b},
$S:0}
C.bcl.prototype={
$0(){return this.a.e=null},
$S:0}
C.bcn.prototype={
$1(d){return this.a.vC(this.b,d)},
$S:6}
C.b3K.prototype={
$1(d){var w=J.a6(d)
return A.k(w.h(d,"quantity"))+"\xd7 "+A.k(w.h(d,"name"))},
$S:105}
C.b3L.prototype={
$2(d,e){var w,v,u,t=null,s=e.a
if(s===0)$.al.aQ$.push(new C.b3J(this.a))
w=A.V(4)
s=B.m.bW(s,1e6)
v=s>30?B.l:B.G
u=A.c(d).ax.a===B.b?B.D:B.E
return A.W(A.a([A.fQ(w,E.bts(u,v,5,s/180,t)),B.aD,A.j(E.byE(e)+" left to answer",t,t,t,t,A.t(t,t,this.b,t,t,t,t,t,t,t,t,12,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t,t)],x.p),B.p,t,B.e,B.f,0,B.k)},
$S:764}
C.b3J.prototype={
$1(d){return this.a.f.$0()},
$S:4}
C.b3M.prototype={
$0(){return this.a.e.$1(!1)},
$S:0}
C.b3N.prototype={
$0(){return this.a.e.$1(!0)},
$S:0}
C.bcr.prototype={
$0(){return this.a.d=this.b},
$S:0}
C.bcT.prototype={
$0(){return this.a.y=!0},
$S:0}
C.bcU.prototype={
$0(){return this.a.y=!1},
$S:0}
C.bcW.prototype={
$1(d){return A.k(d)},
$S:105}
C.bcZ.prototype={
$4(d,e,f,g){var w,v,u,t=this,s=null
if(f)w=B.H
else w=A.c(t.a).ax.a===B.b?B.as:B.ar
if(f)v=B.H
else v=A.c(t.a).ax.a===B.b?B.D:B.E
v=A.aW(v,B.n,1)
u=f?D.XV:A.j(""+d,s,s,s,s,A.t(s,s,t.b,s,s,s,s,s,s,s,s,s,s,s,B.A,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s)
v=A.a1(B.a5,u,B.j,s,s,new A.X(w,s,v,s,s,s,B.av),s,28,s,s,s,s,s,28)
w=f?B.Ji:s
w=A.a([v,B.aB,A.aa(A.j(e,s,s,s,s,A.t(s,s,t.c,s,w,s,s,s,s,s,s,s,s,s,B.z,s,s,!0,s,s,s,s,s,s,s,s),s,s,s,s),1)],x.p)
if(!f&&g!=null)w.push(g)
return new A.Z(B.bR,A.R(w,B.i,s,B.e,B.f,0,s),s)},
$S:765}
C.bcX.prototype={
$0(){var w=0,v=A.q(x.H),u=this
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:w=2
return A.h(A.dL(u.b,B.tp,x.H),$async$$0)
case 2:w=3
return A.h(u.a.Bk(),$async$$0)
case 3:return A.o(null,v)}})
return A.p($async$$0,v)},
$S:2}
C.bcY.prototype={
$1(d){var w=this.a
return w.p(new C.bcV(w,this.b))},
$S:6}
C.bcV.prototype={
$0(){return this.a.x=this.b.a},
$S:0};(function installTearOffs(){var w=a._instance_0u,v=a.installInstanceTearOff,u=a._instance_1u
var t
w(t=C.OH.prototype,"gaII","IJ",0)
w(t,"gww","j6",0)
v(C.RB.prototype,"gww",0,0,null,["$1$silent","$0"],["wx","j6"],2,0,0)
w(t=C.TD.prototype,"gww","j6",0)
u(t,"gaEA","aEB",3)
w(t=C.M1.prototype,"gaVD","Mr",0)
u(t,"gaB8","aB9",4)
w(C.TE.prototype,"gFU","jA",0)
w(C.TF.prototype,"ganN","zL",0)
w(t=C.TL.prototype,"gaEK","Bk",0)
w(t,"gaFv","Ia",0)})();(function inheritance(){var w=a.mixinHard,v=a.inheritMany,u=a.inherit
v(A.U,[C.tE,C.aFn])
v(A.ip,[C.aFo,C.bc5,C.aPB,C.aPC,C.aPl,C.aPz,C.b38,C.b35,C.b2X,C.b2V,C.alS,C.aFv,C.aFu,C.aFs,C.aFt,C.bcn,C.b3K,C.b3J,C.bcW,C.bcZ,C.bcY])
v(A.N,[C.tD,C.OG,C.RA,C.TC,C.M2,C.M4,C.M5])
v(A.O,[C.aeL,C.OH,C.aiv,C.TD,C.aj4,C.TF,C.TL])
v(A.ne,[C.bc4,C.aPq,C.aPw,C.aPx,C.aPp,C.aPr,C.aPs,C.aPt,C.aPu,C.aPv,C.aPm,C.aPy,C.aPn,C.aPo,C.b3b,C.b2Y,C.b2Z,C.b3_,C.b30,C.b36,C.b37,C.b39,C.b2W,C.b31,C.b32,C.b33,C.b34,C.bcd,C.bce,C.bcf,C.bcg,C.bcS,C.bcm,C.bck,C.bcl,C.b3M,C.b3N,C.bcr,C.bcT,C.bcU,C.bcX,C.bcV])
v(A.oZ,[C.aPA,C.b3a,C.beh,C.b3L])
u(C.RB,C.aiv)
v(A.a3,[C.aeP,C.afz,C.ac3,C.DR])
u(C.MF,A.yw)
u(C.M1,A.b6)
u(C.TE,C.aj4)
w(C.aiv,H.hE)
w(C.aj4,H.hE)})()
A.z4(b.typeUniverse,JSON.parse('{"OG":{"N":[],"d":[],"e":[]},"RA":{"N":[],"d":[],"e":[]},"TC":{"N":[],"d":[],"e":[]},"tD":{"N":[],"d":[],"e":[]},"aeL":{"O":["tD"]},"OH":{"O":["OG"]},"RB":{"O":["RA"]},"TD":{"O":["TC"]},"aeP":{"a3":[],"d":[],"e":[]},"afz":{"a3":[],"d":[],"e":[]},"M1":{"b6":[],"aA":[]},"M2":{"N":[],"d":[],"e":[]},"TE":{"O":["M2"]},"ac3":{"a3":[],"d":[],"e":[]},"M4":{"N":[],"d":[],"e":[]},"TF":{"O":["M4"]},"M5":{"N":[],"d":[],"e":[]},"TL":{"O":["M5"]},"DR":{"a3":[],"d":[],"e":[]}}'))
var y={a:"https://findfooddelivery-backend.onrender.com/deliveries/offers/",d:"https://findfooddelivery-backend.onrender.com/riders/me/verification"}
var x=(function rtii(){var w=A.aH
return{d:w("l5"),f:w("rv"),V:w("D<d9>"),J:w("D<l8>"),A:w("D<f_>"),s:w("D<r>"),p:w("D<d>"),D:w("Y<aB<r,@>>"),l:w("Y<f_>"),j:w("Y<@>"),P:w("aB<r,@>"),W:w("f_"),L:w("tE"),N:w("r"),O:w("w<r>"),q:w("uw"),y:w("M"),i:w("a_"),z:w("@"),S:w("z"),g:w("Y<@>?"),Q:w("t4?"),H:w("~")}})();(function constants(){var w=a.makeConstList
D.L8=new I.zm("Rider",null)
D.Ox=new A.l8("customer","Customer","Directions and delivery updates")
D.Sa=new A.a2(0,0,0,40)
D.Sc=new A.a2(0,0,12,0)
D.SK=new A.a2(14,12,10,12)
D.SR=new A.a2(15,0,0,0)
D.vO=new A.a2(16,12,16,12)
D.SX=new A.a2(16,12,16,8)
D.vT=new A.a2(20,0,20,14)
D.U_=new I.Aq(44,null)
D.Vy=new A.a5(61734,"MaterialIcons",null,!1)
D.U5=new A.d2(D.Vy,"No deliveries right now","Stay online \u2014 new jobs appear as orders come in.",null,null,null)
D.U9=new A.d2(B.dS,"You're offline","Go online to start seeing available deliveries.",null,null,null)
D.Ua=new A.d2(B.dS,"No deliveries yet","Accept a job from Available tab to get started.",null,null,null)
D.nd=new A.x(!0,null,null,"PlusJakartaSans",null,null,28,B.A,null,-0.8,null,null,1.15,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.alH=new A.aj("Available jobs",null,D.nd,null,null,B.a4,null,null,null,null,null)
D.amg=new A.aj("Tap a job to accept it",null,B.JG,null,null,null,null,null,null,null,null)
D.a3S=w([D.alH,B.bk,D.amg],x.p)
D.Qu=new A.lb(B.V,B.e,B.f,B.p,null,B.k,null,0,D.a3S,null)
D.Uj=new A.dq(1,B.b1,D.Qu,null)
D.Vl=new A.a5(61112,"MaterialIcons",null,!1)
D.VA=new A.a5(61838,"MaterialIcons",null,!1)
D.wL=new A.a5(61958,"MaterialIcons",null,!1)
D.Wh=new A.a5(63510,"MaterialIcons",null,!1)
D.Wk=new A.a5(63618,"MaterialIcons",null,!1)
D.Xi=new A.aJ(F.jt,18,B.w,null,null)
D.XO=new A.aJ(B.fE,18,B.H,null,null)
D.XV=new A.aJ(B.fF,16,B.y,null,null)
D.XZ=new A.aJ(B.Wf,16,B.H,null,null)
D.Ye=new A.aJ(B.cr,16,B.l,null,null)
D.Yo=new A.aJ(B.lM,18,B.w,null,null)
D.Yt=new A.aJ(B.fI,18,B.H,null,null)
D.YE=new A.aJ(B.cr,20,B.ay,null,null)
D.YG=new A.aJ(F.xi,18,null,null,null)
D.Vr=new A.a5(61495,"MaterialIcons",null,!1)
D.axE=new A.a5(63268,"MaterialIcons",null,!1)
D.UV=new A.hB(D.Vr,"Available",0)
D.UW=new A.hB(B.dS,"My Deliveries",0)
D.UQ=new A.hB(B.hW,"Earnings",0)
D.a3B=w([D.UV,D.UW,D.UQ,B.wy],A.aH("D<hB>"))
D.a47=new A.Bl(B.a45,10,null)
D.a6V={motorbike:0,bicycle:1,car:2,on_foot:3}
D.Dg=new A.bD(D.a6V,["Motorbike","Bicycle","Car","On foot"],A.aH("bD<r,r>"))
D.alM=new A.aj("My deliveries",null,D.nd,null,null,null,null,null,null,null,null)
D.a84=new A.Z(B.p1,D.alM,null)
D.St=new A.a2(0,60,0,0)
D.a88=new A.Z(D.St,B.bX,null)
D.abj=new C.M4(null)
D.Yb=new A.aJ(B.q8,18,B.w,null,null)
D.amG=new A.aj("New delivery available!",null,G.Jp,null,null,null,null,null,null,null,null)
D.a3r=w([D.Yb,B.ac,D.amG],x.p)
D.abp=new A.ja(B.aK,B.e,B.f,B.i,null,B.k,null,0,D.a3r,null)
D.k7=new C.MF(0,"idle")
D.Ih=new C.MF(1,"sharing")
D.mW=new C.MF(2,"blocked")
D.an3=new A.aj("Could not open maps.",null,null,null,null,null,null,null,null,null,null)
D.IW=new A.fX(D.an3,null,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.ali=new A.aj("Delivery complete. Nice work!",null,B.b3,null,null,null,null,null,null,null,null)
D.aeF=new A.fX(D.ali,B.H,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.amZ=new A.aj("This order does not have a delivery destination.",null,null,null,null,null,null,null,null,null,null)
D.IX=new A.fX(D.amZ,null,null,null,null,null,null,null,null,null,null,null,null,B.af,!1,null,null,null,B.B,null)
D.nc=new A.x(!0,null,null,"PlusJakartaSans",null,null,12,B.aA,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aiv=new A.x(!0,B.H,null,null,null,null,22,B.dy,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ne=new A.x(!0,null,null,"PlusJakartaSans",null,null,16,B.z,null,-0.1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.kn=new A.x(!0,null,null,"PlusJakartaSans",null,null,13,B.a3,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.alc=new A.aj("Earned today",null,D.kn,null,null,null,null,null,null,null,null)
D.alj=new A.aj("Release this job",null,null,null,null,null,null,null,null,null,null)
D.alr=new A.aj("It goes back to the available jobs for another rider. You can release up to 2 jobs a day, and never after collecting the food.",null,null,null,null,null,null,null,null,null,null)
D.alF=new A.aj("Complete with customer's code",null,null,null,null,null,null,null,null,null,null)
D.amr=new A.aj("Decline",null,null,null,null,null,null,null,null,null,null)
D.amA=new A.aj("Earnings",null,D.nd,null,null,null,null,null,null,null,null)
D.amE=new A.aj("Recent deliveries",null,B.Jz,null,null,null,null,null,null,null,null)
D.an6=new A.aj("Turn on",null,null,null,null,null,null,null,null,null,null)
D.an8=new A.aj("Profile",null,D.nd,null,null,null,null,null,null,null,null)
D.ano=new A.aj("Keep job",null,null,null,null,null,null,null,null,null,null)
D.anu=new A.aj("Release",null,B.km,null,null,null,null,null,null,null,null)
D.anE=new A.aj("Add your MoMo to get paid",null,null,null,null,null,null,null,null,null,null)
D.anG=new A.aj("Accept delivery",null,null,null,null,null,null,null,null,null,null)
D.anL=new A.aj("Add",null,null,null,null,null,null,null,null,null,null)
D.apH=new A.w("rider-add-payout",x.O)
D.apN=new A.w("verify-licence",x.O)
D.aqA=new A.w("rider-owed",x.O)
D.aqL=new A.w("verification-add-phone",x.O)
D.ar3=new A.w("verify-plate",x.O)
D.ar7=new A.w("rider-offers",x.O)
D.arb=new A.w("verify-card",x.O)
D.ark=new A.w("rider-sharing-retry",x.O)
D.arG=new A.w("verify-emergency-name",x.O)
D.arL=new A.w("rider-sharing-banner",x.O)
D.asf=new A.w("verify-submit",x.O)
D.asy=new A.w("confirm-release",x.O)
D.asI=new A.w("rider-payout-card",x.O)
D.at3=new A.w("rider-online-toggle",x.O)
D.atx=new A.w("verify-emergency-phone",x.O)
D.atP=new A.w("verification-pending",x.O)
D.atW=new A.w("verification-rejected",x.O)
D.aus=new A.w("settings-rider-payout",x.O)
D.auu=new A.w("rider-today-earnings",x.O)
D.av0=new C.OG(null)
D.WE=new A.a5(983663,"MaterialIcons",null,!1)
D.av4=new C.DR(B.ay,D.WE,"Riders are checked before their first job","It keeps customers and restaurants safe. It takes a few minutes to fill in.",null)
D.awo=new C.RA(null)
D.awO=new C.TC(null)
D.awQ=new C.aeP(null)
D.ax_=new C.afz(null)})();(function lazyInitializers(){var w=a.lazyFinal
w($,"bTi","akm",()=>new C.M1(D.k7,$.ab()))})()};
(a=>{a["Mz6F1HxjvkzfdXszYs4Ur04DK6E="]=a.current})($__dart_deferred_initializers__);