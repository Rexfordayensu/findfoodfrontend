((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={zj:function zj(d,e){this.c=d
this.a=e},a4f:function a4f(d){this.a=d},aIE:function aIE(d){this.a=d},An:function An(d,e){this.c=d
this.a=e},PY:function PY(){this.d=!1
this.c=this.a=null},aVT:function aVT(d){this.a=d},aVU:function aVU(d){this.a=d},aca:function aca(d,e){this.c=d
this.a=e},b5x:function b5x(d){this.a=d},b5y:function b5y(d,e){this.a=d
this.b=e},
a_h(d,e,f,g){var w=null
return new A.Ip(!0,g,w,w,w,w,B.j,w,!1,w,!0,w,new C.a9l(f,d,w,w,w),e)},
a9l:function a9l(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
XJ(d,e,f){var w=0,v=A.q(x.y),u,t,s,r
var $async$XJ=A.m(function(g,h){if(g===1)return A.n(h,v)
for(;;)switch(w){case 0:s=A.K6("POST",A.aq(y.b,0,null))
s.r.n(0,"Authorization","Bearer "+f)
s.y.push(A.K5("file",e,A.Gx(d),d))
r=A
w=4
return A.h($.aF().ew(0,s),$async$XJ)
case 4:w=3
return A.h(r.pX(h),$async$XJ)
case 3:t=h
if(t.b===200){u=A.bf(t)
w=1
break}throw A.i(A.ag(A.bp(t,"Could not upload your photo")))
case 1:return A.o(u,v)}})
return A.p($async$XJ,v)},
alk(d){var w=0,v=A.q(x.y),u,t,s
var $async$alk=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.w
w=3
return A.h($.aF().tD(0,A.aq(y.b,0,null),A.L(["Authorization","Bearer "+d],t,t)),$async$alk)
case 3:s=f
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bp(s,"Could not remove your photo")))
case 1:return A.o(u,v)}})
return A.p($async$alk,v)}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[11],C)
D=c[15]
C.zj.prototype={
t(d){var w,v,u=null,t=A.af(d,!0,x.e),s=t.f,r=s==null?u:B.d.a3(s).length!==0
if(r===!0){s.toString
w=s}else w="Your account"
s=x.u
r=A.a([A.j(w,B.Kl,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.t:B.r,u,u,u,u,u,u,u,u,18,u,u,B.A,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u)],s)
v=t.r
if(v!=null&&v.length!==0)r.push(A.j(v,B.Kj,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.v:B.u,u,u,u,u,u,u,u,u,13,u,u,u,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u))
r.push(new A.a0(B.oS,A.j(this.c,u,u,u,u,B.rU,u,u,u,u),u))
return A.V(A.a([D.TV,B.dD,A.ad(A.U(r,B.q,u,B.e,B.f,0,B.k),1)],s),B.i,u,B.e,B.f,0,u)}}
C.a4f.prototype={
t(d){return new A.AL("Sign out",new C.aIE(d),B.Kf)}}
C.An.prototype={
L(){return new C.PY()}}
C.PY.prototype={
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
return A.h(A.dT(j,new C.aca(h.length!==0,null),x.w),$async$mN)
case 3:o=e
if(o==null||q.c==null){w=1
break}q.p(new C.aVT(q))
t=5
w=o==="remove"?8:9
break
case 8:h=p.c
h.toString
w=10
return A.h(C.alk(h),$async$mN)
case 10:n=e
h=J.B(n,"avatar_url")
h=h==null?null:J.bH(h)
w=11
return A.h(p.ve(h),$async$mN)
case 11:h=q.c
if(h!=null)A.b1(h,"Photo removed.",!1)
r=[1]
w=6
break
case 9:w=12
return A.h(new A.pm().uG(85,800,800,B.hV),$async$mN)
case 12:m=e
if(m==null){r=[1]
w=6
break}h=p.c
h.toString
w=13
return A.h(m.p5(),$async$mN)
case 13:j=e
w=14
return A.h(C.XJ(m.b,j,h),$async$mN)
case 14:l=e
h=J.B(l,"avatar_url")
h=h==null?null:J.bH(h)
w=15
return A.h(p.ve(h),$async$mN)
case 15:h=q.c
if(h!=null)A.b1(h,"Looking good! Photo updated.",!1)
r.push(7)
w=6
break
case 5:t=4
g=s.pop()
k=A.a3(g)
h=q.c
if(h!=null)A.b1(h,A.b9(k),!0)
r.push(7)
w=6
break
case 4:r=[2]
case 6:t=2
if(q.c!=null)q.p(new C.aVU(q))
w=r.pop()
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$mN,v)},
t(d){var w,v,u=this,t=null,s=A.af(d,!0,x.e),r=u.a.c,q=u.d?t:u.gaq3(),p=r+4,o=A.a([new A.Dz(s.f,s.w,r,t)],x.u)
if(u.d){w=r*0.36
o.push(A.KU(4,A.bqu(A.A2(A.c3(A.bw(D.OC,w,w),t,t),B.ol,!0)),4))}w=r*0.38
v=A.aZ(A.c(d).ax.a===B.c?B.c3:B.y,B.n,2)
o.push(A.h8(0,A.a2(t,A.ao(D.q2,B.x,t,t,r*0.2),B.j,t,t,new A.Y(B.m,t,v,t,t,t,B.av),t,w,t,t,t,t,t,w),t,t,t,0,t,t))
return A.bj(t,!0,t,A.cf(t,A.bw(new A.dx(B.bg,t,B.bs,B.j,o,t),p,p),B.L,!1,D.arA,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,q,t,t,t,t,t,t,!1,B.aa),!1,t,t,t,!1,t,!1,t,t,t,t,t,t,t,t,t,t,"Profile photo. Tap to change it.",t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,B.M,t)}}
C.aca.prototype={
t(d){var w=new C.b5x(d),v=this.c,u=A.a([D.acl,w.$3("choose",D.wE,v?"Choose a new photo":"Add a photo")],x.u)
if(v)u.push(w.$4$color("remove",B.jo,"Remove photo",B.H))
return A.U(u,B.q,null,B.e,B.Y,0,B.k)}}
C.a9l.prototype={
t(d){var w,v=null,u=A.bz(d,B.aN)
u=u==null?v:u.gbP()
u=A.K((u==null?B.au:u).aJ(0,14)/14,1,2)
A.brr(d)
u=A.at(8,4,u-1)
u.toString
w=A.a([this.d,new A.eB(1,B.bD,this.c,v)],x.u)
return A.V(w,B.i,v,B.e,B.Y,u,v)}}
var z=a.updateTypes(["ap<~>()"])
C.aIE.prototype={
$0(){var w=0,v=A.q(x.v),u,t=this,s
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:s=t.a
w=3
return A.h(A.zb(s),$async$$0)
case 3:if(!e||s.e==null){w=1
break}w=4
return A.h(A.af(s,!1,x.e).np(),$async$$0)
case 4:if(s.e==null){w=1
break}A.ajT(s)
A.bN(s).cs(0,"/",null)
case 1:return A.o(u,v)}})
return A.p($async$$0,v)},
$S:2}
C.aVT.prototype={
$0(){return this.a.d=!0},
$S:0}
C.aVU.prototype={
$0(){return this.a.d=!1},
$S:0}
C.b5x.prototype={
$4$color(d,e,f,g){var w,v=null,u=g==null
if(u)w=A.c(this.a).ax.a===B.c?B.t:B.r
else w=g
w=A.ao(e,w,v,v,v)
if(u)u=A.c(this.a).ax.a===B.c?B.t:B.r
else u=g
return A.iZ(!1,B.X,v,v,!0,v,v,v,!0,v,new A.y("avatar-"+d,x.q),w,v,v,v,v,new C.b5y(this.a,d),!1,v,v,v,v,v,v,v,A.j(f,v,v,v,v,A.t(v,v,u,v,v,v,v,v,v,v,v,v,v,v,B.a3,v,v,!0,v,v,v,v,v,v,v,v),v,v,v,v),v,v,v)},
$3(d,e,f){return this.$4$color(d,e,f,null)},
$S:821}
C.b5y.prototype={
$0(){return A.b_(this.a,!1).aX(this.b)},
$S:0};(function installTearOffs(){var w=a._instance_0u
w(C.PY.prototype,"gaq3","mN",0)})();(function inheritance(){var w=a.inheritMany,v=a.inherit
w(A.a5,[C.zj,C.a4f,C.aca,C.a9l])
w(A.na,[C.aIE,C.aVT,C.aVU,C.b5y])
v(C.An,A.N)
v(C.PY,A.O)
v(C.b5x,A.im)})()
A.uy(b.typeUniverse,JSON.parse('{"zj":{"a5":[],"d":[],"e":[]},"a4f":{"a5":[],"d":[],"e":[]},"An":{"N":[],"d":[],"e":[]},"PY":{"O":["An"]},"aca":{"a5":[],"d":[],"e":[]},"a9l":{"a5":[],"d":[],"e":[]}}'))
var y={b:"https://findfooddelivery-backend.onrender.com/auth/me/avatar"}
var x={e:A.aE("l2"),u:A.aE("D<d>"),y:A.aE("aD<r,@>"),w:A.aE("r"),q:A.aE("y<r>"),v:A.aE("~")};(function constants(){D.OC=new A.fg(2.4,null,null,null,null,B.y,null,null,null,null)
D.ja=new A.a1(0,0,0,4)
D.TV=new C.An(60,null)
D.pN=new A.a4(60979,"MaterialIcons",null,!1)
D.wE=new A.a4(62109,"MaterialIcons",null,!1)
D.q2=new A.a4(983181,"MaterialIcons",null,!1)
D.qa=new A.aR(B.lT,null,null,null,null)
D.acl=new A.ed("Profile photo","Optional. It helps restaurants and riders recognise you.",null)
D.rn=new C.a4f(null)
D.Js=new A.x(!0,B.H,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.arA=new A.y("edit-avatar",x.q)})()};
(a=>{a["9CCBSWklFCHdnTXzna+ci6i4iCI="]=a.current})($__dart_deferred_initializers__);