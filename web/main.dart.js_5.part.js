((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={zj:function zj(d,e){this.c=d
this.a=e},a49:function a49(d){this.a=d},aIt:function aIt(d){this.a=d},An:function An(d,e){this.c=d
this.a=e},PV:function PV(){this.d=!1
this.c=this.a=null},aVI:function aVI(d){this.a=d},aVJ:function aVJ(d){this.a=d},ac3:function ac3(d,e){this.c=d
this.a=e},b5j:function b5j(d){this.a=d},b5k:function b5k(d,e){this.a=d
this.b=e},
a_d(d,e,f,g){var w=null
return new A.Ik(!0,g,w,w,w,w,B.j,w,!1,w,!0,w,new C.a9f(f,d,w,w,w),e)},
a9f:function a9f(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
XE(d,e,f){var w=0,v=A.q(x.y),u,t,s,r
var $async$XE=A.m(function(g,h){if(g===1)return A.n(h,v)
for(;;)switch(w){case 0:s=A.K2("POST",A.as(y.b,0,null))
s.r.n(0,"Authorization","Bearer "+f)
s.y.push(A.K1("file",e,A.Gt(d),d))
r=A
w=4
return A.h($.aH().ew(0,s),$async$XE)
case 4:w=3
return A.h(r.pW(h),$async$XE)
case 3:t=h
if(t.b===200){u=A.bg(t)
w=1
break}throw A.i(A.ah(A.bq(t,"Could not upload your photo")))
case 1:return A.o(u,v)}})
return A.p($async$XE,v)},
alb(d){var w=0,v=A.q(x.y),u,t,s
var $async$alb=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.w
w=3
return A.h($.aH().tD(0,A.as(y.b,0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$alb)
case 3:s=f
if(s.b===200){u=A.bg(s)
w=1
break}throw A.i(A.ah(A.bq(s,"Could not remove your photo")))
case 1:return A.o(u,v)}})
return A.p($async$alb,v)}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[10],C)
D=c[14]
C.zj.prototype={
t(d){var w,v,u=null,t=A.af(d,!0,x.e),s=t.f,r=s==null?u:B.d.a3(s).length!==0
if(r===!0){s.toString
w=s}else w="Your account"
s=x.u
r=A.a([A.j(w,B.Ke,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.t:B.r,u,u,u,u,u,u,u,u,18,u,u,B.C,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u)],s)
v=t.r
if(v!=null&&v.length!==0)r.push(A.j(v,B.Kc,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.v:B.u,u,u,u,u,u,u,u,u,13,u,u,u,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u))
r.push(new A.a0(B.oR,A.j(this.c,u,u,u,u,B.rP,u,u,u,u),u))
return A.V(A.a([D.TM,B.e2,A.ae(A.U(r,B.q,u,B.e,B.f,0,B.k),1)],s),B.i,u,B.e,B.f,0,u)}}
C.a49.prototype={
t(d){return new A.AL("Sign out",new C.aIt(d),B.K8)}}
C.An.prototype={
L(){return new C.PV()}}
C.PV.prototype={
mN(){var w=0,v=A.q(x.v),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g
var $async$mN=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.c
h.toString
p=A.af(h,!1,x.e)
h=p.w
if(h==null)h=""
j=q.c
j.toString
w=3
return A.h(A.e8(j,new C.ac3(h.length!==0,null),x.w),$async$mN)
case 3:o=e
if(o==null||q.c==null){w=1
break}q.p(new C.aVI(q))
t=5
w=o==="remove"?8:9
break
case 8:h=p.c
h.toString
w=10
return A.h(C.alb(h),$async$mN)
case 10:n=e
h=J.B(n,"avatar_url")
h=h==null?null:J.bH(h)
w=11
return A.h(p.ve(h),$async$mN)
case 11:h=q.c
if(h!=null)A.b7(h,"Photo removed.",!1)
r=[1]
w=6
break
case 9:w=12
return A.h(new A.pk().uG(85,800,800,B.hT),$async$mN)
case 12:m=e
if(m==null){r=[1]
w=6
break}h=p.c
h.toString
w=13
return A.h(m.p5(),$async$mN)
case 13:j=e
w=14
return A.h(C.XE(m.b,j,h),$async$mN)
case 14:l=e
h=J.B(l,"avatar_url")
h=h==null?null:J.bH(h)
w=15
return A.h(p.ve(h),$async$mN)
case 15:h=q.c
if(h!=null)A.b7(h,"Looking good! Photo updated.",!1)
r.push(7)
w=6
break
case 5:t=4
g=s.pop()
k=A.a2(g)
h=q.c
if(h!=null)A.b7(h,A.b9(k),!0)
r.push(7)
w=6
break
case 4:r=[2]
case 6:t=2
if(q.c!=null)q.p(new C.aVJ(q))
w=r.pop()
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$mN,v)},
t(d){var w,v,u=this,t=null,s=A.af(d,!0,x.e),r=u.a.c,q=u.d?t:u.gapZ(),p=r+4,o=A.a([new A.Dw(s.f,s.w,r,t)],x.u)
if(u.d){w=r*0.36
o.push(A.KQ(4,A.bq4(A.A2(A.c7(A.bw(D.Ot,w,w),t,t),B.ok,!0)),4))}w=r*0.38
v=A.aZ(A.c(d).ax.a===B.c?B.c2:B.x,B.n,2)
o.push(A.h8(0,A.a3(t,A.ao(D.q_,B.y,t,t,r*0.2),B.j,t,t,new A.Z(B.m,t,v,t,t,t,B.as),t,w,t,t,t,t,t,w),t,t,t,0,t,t))
return A.bj(t,!0,t,A.ch(t,A.bw(new A.dx(B.bg,t,B.br,B.j,o,t),p,p),B.L,!1,D.ar6,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,q,t,t,t,t,t,t,!1,B.aa),!1,t,t,t,!1,t,!1,t,t,t,t,t,t,t,t,t,t,"Profile photo. Tap to change it.",t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,B.M,t)}}
C.ac3.prototype={
t(d){var w=new C.b5j(d),v=this.c,u=A.a([D.ac3,w.$3("choose",D.wx,v?"Choose a new photo":"Add a photo")],x.u)
if(v)u.push(w.$4$color("remove",B.jm,"Remove photo",B.H))
return A.U(u,B.q,null,B.e,B.Y,0,B.k)}}
C.a9f.prototype={
t(d){var w,v=null,u=A.bz(d,B.aN)
u=u==null?v:u.gbP()
u=A.K((u==null?B.ar:u).aJ(0,14)/14,1,2)
A.br1(d)
u=A.at(8,4,u-1)
u.toString
w=A.a([this.d,new A.eB(1,B.bB,this.c,v)],x.u)
return A.V(w,B.i,v,B.e,B.Y,u,v)}}
var z=a.updateTypes(["ar<~>()"])
C.aIt.prototype={
$0(){var w=0,v=A.q(x.v),u,t=this,s
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:s=t.a
w=3
return A.h(A.zb(s),$async$$0)
case 3:if(!e||s.e==null){w=1
break}w=4
return A.h(A.af(s,!1,x.e).np(),$async$$0)
case 4:if(s.e==null){w=1
break}A.ajK(s)
A.bN(s).cs(0,"/",null)
case 1:return A.o(u,v)}})
return A.p($async$$0,v)},
$S:2}
C.aVI.prototype={
$0(){return this.a.d=!0},
$S:0}
C.aVJ.prototype={
$0(){return this.a.d=!1},
$S:0}
C.b5j.prototype={
$4$color(d,e,f,g){var w,v=null,u=g==null
if(u)w=A.c(this.a).ax.a===B.c?B.t:B.r
else w=g
w=A.ao(e,w,v,v,v)
if(u)u=A.c(this.a).ax.a===B.c?B.t:B.r
else u=g
return A.iZ(!1,B.X,v,v,!0,v,v,v,!0,v,new A.y("avatar-"+d,x.q),w,v,v,v,v,new C.b5k(this.a,d),!1,v,v,v,v,v,v,v,A.j(f,v,v,v,v,A.t(v,v,u,v,v,v,v,v,v,v,v,v,v,v,B.a1,v,v,!0,v,v,v,v,v,v,v,v),v,v,v,v),v,v,v)},
$3(d,e,f){return this.$4$color(d,e,f,null)},
$S:819}
C.b5k.prototype={
$0(){return A.b_(this.a,!1).aX(this.b)},
$S:0};(function installTearOffs(){var w=a._instance_0u
w(C.PV.prototype,"gapZ","mN",0)})();(function inheritance(){var w=a.inheritMany,v=a.inherit
w(A.a6,[C.zj,C.a49,C.ac3,C.a9f])
w(A.n7,[C.aIt,C.aVI,C.aVJ,C.b5k])
v(C.An,A.N)
v(C.PV,A.O)
v(C.b5j,A.im)})()
A.z1(b.typeUniverse,JSON.parse('{"zj":{"a6":[],"d":[],"e":[]},"a49":{"a6":[],"d":[],"e":[]},"An":{"N":[],"d":[],"e":[]},"PV":{"O":["An"]},"ac3":{"a6":[],"d":[],"e":[]},"a9f":{"a6":[],"d":[],"e":[]}}'))
var y={b:"https://findfooddelivery-backend.onrender.com/auth/me/avatar"}
var x={e:A.aG("l0"),u:A.aG("D<d>"),y:A.aG("aD<r,@>"),w:A.aG("r"),q:A.aG("y<r>"),v:A.aG("~")};(function constants(){D.Ot=new A.fx(2.4,null,null,null,null,B.x,null,null,null,null)
D.j7=new A.a1(0,0,0,4)
D.TM=new C.An(60,null)
D.pM=new A.a5(60979,"MaterialIcons",null,!1)
D.wx=new A.a5(62109,"MaterialIcons",null,!1)
D.q_=new A.a5(983181,"MaterialIcons",null,!1)
D.q7=new A.aS(B.lS,null,null,null,null)
D.ac3=new A.en("Profile photo","Optional. It helps restaurants and riders recognise you.",null)
D.ri=new C.a49(null)
D.Jl=new A.x(!0,B.H,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.ar6=new A.y("edit-avatar",x.q)})()};
(a=>{a["MwWog5Vjb7nDrqwIo76cotMAtDg="]=a.current})($__dart_deferred_initializers__);