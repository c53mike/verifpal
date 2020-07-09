Require Import Coq.Lists.List Coq.Bool.Bool Coq.Arith.PeanoNat
        Lia Coq.Strings.String.
        Import ListNotations.

Inductive generator :=
| G.

Inductive guard_status: Type :=
| guarded
| unguarded.

Inductive constant : Type :=
| Nil
| cnstn : string -> constant
with primitive : Type :=
| ENC : value -> value -> primitive
| DEC : value -> value -> primitive
| AEAD_ENC : value -> value -> value -> primitive
| AEAD_DEC : value -> value -> value -> primitive
| PKE_ENC : value -> value -> primitive
| PKE_DEC : value -> value -> primitive
| HASH1 : value -> primitive
| HASH2 : value -> value -> primitive
| HASH3 : value -> value -> value -> primitive
| HASH4 : value -> value -> value -> value -> primitive
| HASH5 : value -> value -> value -> value -> value -> primitive
| MAC : value -> value -> primitive
| HKDF1: value -> value -> value -> primitive
| HKDF2: value -> value -> value -> primitive
| HKDF3: value -> value -> value -> primitive
| HKDF4: value -> value -> value -> primitive
| HKDF5: value -> value -> value -> primitive
| PW_HASH1 : value -> primitive
| PW_HASH2 : value -> value -> primitive
| PW_HASH3 : value -> value -> value -> primitive
| PW_HASH4 : value -> value -> value -> value -> primitive
| PW_HASH5 : value -> value -> value -> value -> value -> primitive
| SIGN: value -> value -> primitive
| SIGNVERIF: value -> value -> value -> primitive
| RINGSIGN: value -> value -> value -> value -> primitive
| RINGSIGNVERIF: value -> value -> value -> value -> value -> primitive
| BLIND: value -> value -> primitive
| UNBLIND: value -> value -> value -> primitive
| SHAMIR_SPLIT1: value -> primitive
| SHAMIR_SPLIT2: value -> primitive
| SHAMIR_SPLIT3: value -> primitive
| SHAMIR_JOIN: value -> value -> primitive
| CONCAT2 : value -> value -> primitive
| CONCAT3 : value -> value -> value -> primitive
| CONCAT4 : value -> value -> value -> value -> primitive
| CONCAT5 : value -> value -> value -> value -> value -> primitive
| SPLIT1: value -> primitive
| SPLIT2: value -> primitive
| SPLIT3: value -> primitive
| SPLIT4: value -> primitive
| SPLIT5: value -> primitive
  with equation : Type :=
| PUBKEY : generator -> value -> equation
| DH : generator -> value -> value -> equation
  with value : Type :=
| pass : constant -> value
| const : constant -> value 
| eq : equation -> value
| prim : primitive -> value
| default.

Inductive qualifier : Type :=
| public
| private.

Inductive declaration : Type :=
| assignment
| generation
| knowledge.

Inductive leak_status : Type :=
| leaked
| unleaked.

Inductive expression : Type :=
| EXP: declaration -> qualifier -> value -> leak_status -> expression.

(* if qualifier = public -> can learn*)
(* if leak_status = leaked -> can learn*)
(* if sent over the wire -> can learn*)
(* when learning, need to check if attacker already knows equivalent value,
    but maybe this isn't necessary *)

(* 
Variable enc_dec :
  forall (k m : value), DEC k (ENC k m) = m. *)

(* It has no axioms attached to Hash *)

(* 

Variable pke_enc_correcntess : 
   PKE_DEC k (PKE_ENC((PUBKEY G k), m)) = m *)

(* Variable public : value -> Prop.
Variable encryption_constructor : value -> value -> value.
Variable hash_constructor : value -> value. *)

Inductive knows : value -> Type :=
(*equations*)
| public_key_generation (a ga: value) : knows a -> ga = (eq(PUBKEY G a)) -> knows ga
| dh_agreement_primitive (ga b a gab: value) (p: primitive): knows ga -> ga = 
  (eq(PUBKEY G a)) -> knows b -> b = prim p -> gab = (eq(DH G a b)) -> knows gab
| dh_agreement_constant (ga b a gab: value) (c: constant): knows ga -> ga = 
  eq(PUBKEY G a) -> knows b -> b = const c -> gab = (eq(DH G a b)) -> knows gab
(*core primitives*)    
      (* todo: assert*)
| concat2_constructor (a b out: value) : knows a -> knows b -> out = prim(CONCAT2 a b)
  -> knows out
| concat2_corerule_one (val a b : value) : knows val -> val = prim (CONCAT2 a b) -> knows a
| concat2_corerule_two (val a b : value) : knows val -> val = prim (CONCAT2 a b) -> knows b

| concat3_constructor (a b c out: value) : knows a -> knows b -> knows c
  -> out = prim(CONCAT3 a b c) -> knows out
| concat3_corerule_one (val a b c : value) : knows val -> val = prim (CONCAT3 a b c) -> knows a
| concat3_corerule_two (val a b c : value) : knows val -> val = prim (CONCAT3 a b c) -> knows b
| concat3_corerule_three (val a b c : value) : knows val -> val = prim (CONCAT3 a b c) -> knows c

| concat4_constructor (a b c d out: value) : knows a -> knows b -> knows c -> knows d
  -> out = prim(CONCAT4 a b c d) -> knows out
| concat4_corerule_one (val a b c d: value) : knows val -> val = prim (CONCAT4 a b c d) -> knows a
| concat4_corerule_two (val a b c d: value) : knows val -> val = prim (CONCAT4 a b c d) -> knows b
| concat4_corerule_three (val a b c d: value) : knows val -> val = prim (CONCAT4 a b c d) -> knows c
| concat4_corerule_four (val a b c d: value) : knows val -> val = prim (CONCAT4 a b c d) -> knows d

| concat5_constructor (a b c d e out: value) : knows a -> knows b -> knows c -> knows d -> knows e
  -> out = prim(CONCAT5 a b c d e) -> knows out
| concat5_corerule_one (val a b c d e: value) : knows val -> val = prim (CONCAT5 a b c d e) -> knows a
| concat5_corerule_two (val a b c d e: value) : knows val -> val = prim (CONCAT5 a b c d e) -> knows b
| concat5_corerule_three (val a b c d e: value) : knows val -> val = prim (CONCAT5 a b c d e) -> knows c
| concat5_corerule_four (val a b c d e: value) : knows val -> val = prim (CONCAT5 a b c d e) -> knows d
| concat5_corerule_fives (val a b c d e: value) : knows val -> val = prim (CONCAT5 a b c d e) -> knows e

(*hashing primitives*)
| hash1_constructor (a out: value) : knows a -> out = prim(HASH1 a) -> knows out
| hash2_constructor (a b out: value) : knows a -> knows b -> out = prim(HASH2 a b) -> knows out
| hash3_constructor (a b c out: value) : knows a -> knows b -> knows c -> out = prim(HASH3 a b c) -> knows out
| hash4_constructor (a b c d out: value) : knows a -> knows b -> knows c -> knows d -> out = prim(HASH4 a b c d) -> knows out
| hash5_constructor (a b c d e out: value) : knows a -> knows b -> knows c -> knows d -> knows e -> out = prim(HASH5 a b c d e) -> knows out
| mac_constructor (a b out: value) : knows a -> knows b -> out = prim(MAC a b) -> knows out
| hkdf1_constructor (salt ikm info out: value) : knows salt -> knows ikm -> knows info
  -> out = prim(HKDF1 salt ikm info) -> knows out
| hkdf2_constructor (salt ikm info out: value) : knows salt -> knows ikm -> knows info
  -> out = prim(HKDF2 salt ikm info) -> knows out
| hkdf3_constructor (salt ikm info out: value) : knows salt -> knows ikm -> knows info
  -> out = prim(HKDF3 salt ikm info) -> knows out
| hkdf4_constructor (salt ikm info out: value) : knows salt -> knows ikm -> knows info
  -> out = prim(HKDF4 salt ikm info) -> knows out
| hkdf5_constructor (salt ikm info out: value) : knows salt -> knows ikm -> knows info
  -> out = prim(HKDF5 salt ikm info) -> knows out
  |pw_hash1_constructor (a out: value) : knows a -> out = prim(PW_HASH1 a) -> knows out
  |pw_hash2_constructor (a b out: value) : knows a -> knows b -> out = prim(PW_HASH2 a b) -> knows out
  |pw_hash3_constructor (a b c out: value) : knows a -> knows b -> knows c -> out = prim(PW_HASH3 a b c) -> knows out
  |pw_hash4_constructor (a b c d out: value) : knows a -> knows b -> knows c -> knows d -> out = prim(PW_HASH4 a b c d) -> knows out
  |pw_hash5_constructor (a b c d e out: value) : knows a -> knows b -> knows c -> knows d -> knows e -> out = prim(PW_HASH5 a b c d e) -> knows out

(*encryption primitives*)
    (*symmetric encryption*)
| enc_constructor (k m out: value) : knows k -> knows m -> out = prim(ENC k m) -> knows out
| enc_decomposerule (k c m : value) : knows k -> knows c -> c = prim(ENC k m) -> knows m
| dec_constructor (k c m out: value) : knows k -> knows c -> c = prim(ENC k m)
  -> out = prim(DEC k c) -> knows out
| dec_rewriterule (c k m: value) : knows c -> c = prim(DEC k (prim(ENC k m))) -> knows m
    (*authenticated encryption with additional data*)
| aead_enc_constructor (k m ad out: value) : knows k -> knows m -> knows ad
   -> out = prim(AEAD_ENC k m ad) -> knows out
| aead_enc_decomposerule (k c ad m: value): knows k -> knows c -> c = prim(AEAD_ENC k m ad)
  -> knows ad -> knows m
    (*public key encryption*)
| pke_enc_constructor (gk m k out: value): knows gk -> gk = eq(PUBKEY G k) -> knows m
  -> out = prim(PKE_ENC gk m) -> knows out
| pke_enc_decomposerule (k c gk m: value): knows k -> knows gk -> gk = eq(PUBKEY G k)
  -> knows c -> c = prim(PKE_ENC gk m) -> knows m
| pke_dec_constructor(k c gk m out: value): knows k -> knows c -> c = prim(PKE_ENC gk m)
  -> out = prim(PKE_DEC k (prim(PKE_ENC gk m))) -> knows out
| pke_dec_rewriterule(c k m: value): knows c -> c = prim(PKE_DEC k (prim(PKE_ENC (eq(PUBKEY G k))m)))
  -> knows m

(*signature primitives*)
    (*classical digital signatures*)
| sign_constructor(k m out: value): knows k -> knows m -> out = prim(SIGN k m) -> knows out
| signverif_constructor(gk m s k out: value): knows gk -> gk = eq(PUBKEY G k) -> knows m -> knows s -> 
  s = prim(SIGN k m) -> out = prim(SIGNVERIF gk m s) -> knows out
| signverif_rewriterule(val k m s: value): knows val -> val = prim(SIGNVERIF (eq(PUBKEY G k)) m (prim(SIGN k m))) -> knows m

    (*ring signatures*)
| ringsign_constructor(ka gkb gkc m kb kc out: value): knows ka -> knows gkb -> gkb = eq(PUBKEY G kb) ->
    knows gkc -> gkc = eq(PUBKEY G kc) -> knows m -> out = prim(RINGSIGN ka gkb gkc m) -> knows out

      (*unsure about ringsignverif*)
      (*todo: ringsignverif_constructor*)
| ringsignverif_constructor(gka gkb gkc m s out ka kb kc: value): knows gka -> gka = eq(PUBKEY G ka)
  -> knows gkb -> gkb = eq(PUBKEY G kb) -> knows gkc -> gkc = eq(PUBKEY G kc) -> knows m
    -> knows s -> s = prim(RINGSIGN ka gkb gkc m) -> out = prim(RINGSIGNVERIF gka gkb gkc m s) -> knows out
| ringsignverif_rewriterule(gka gkb gkc m s ka kb kc: value): knows gka -> gka = eq(PUBKEY G ka) -> knows gkb -> gkb = eq(PUBKEY G kb)
  -> knows gkc -> gkc = eq(PUBKEY G kc) -> knows m -> knows s -> s = prim(RINGSIGN ka gkb gkc m) -> knows m

    (*blind signatures*)
| blind_constructor(k m out: value): knows k -> knows m -> out = prim(BLIND k m) -> knows out
| blind_decomposerule(k b m: value): knows k -> knows b -> b = prim(BLIND k m) -> knows m
| unblind_constructor(k m s a out: value): knows k -> knows m -> knows s -> 
  s = prim(SIGN a (prim(BLIND k m))) -> out = prim(UNBLIND k m s) -> knows out
| unblind_rewriterule(u k m a out: value): knows u ->
  u = prim(UNBLIND k m (prim(SIGN a (prim(BLIND k m))))) -> out = prim(SIGN a m) -> knows out

(*secret sharing*)
    (*unsure about shamir_split/shamir_join*)
| shamir_split1_constructor(k out: value): knows k -> out = prim(SHAMIR_SPLIT1 k) -> knows out
| shamir_split2_constructor(k out: value): knows k -> out = prim(SHAMIR_SPLIT2 k) -> knows out
| shamir_split3_constructor(k out: value): knows k -> out = prim(SHAMIR_SPLIT3 k) -> knows out
  (*todo: shamir_split_recomposerule*)
  (*todo: shamir_join_constructor*)
  (*todo: shamir_join_rebuildrule*).

Lemma concat2_rule : forall (a b val : value),
    knows val -> val = prim (CONCAT2 a b) ->
    (knows a * knows b)%type.
Proof using.
  intros a b val Hk Hv.
  pose proof (concat2_corerule_one _ _ _ Hk Hv).
  pose proof (concat2_corerule_two _ _ _ Hk Hv).
  auto.
Qed.

Lemma concat2_cons_rule : forall  (a b val : value), knows a -> knows b -> val = prim (CONCAT2 a b) ->
                                               knows val.
Proof using.
  intros.  apply concat2_constructor with (a := a) (b := b); assumption.
Qed.

Theorem insecure : forall (a c m k : value), knows c -> knows a -> k = prim (HASH1 a) ->
                                        c = prim (ENC k m) -> knows m.
Proof using.
  intros.
  pose proof (hash1_constructor _ _ H0 H1).
  apply enc_decomposerule with (k := k) (c := c); assumption.
Qed.

  (* the task is to come up with natural deduction style rules for "knows"*)

Fixpoint value_beq (v1 v2: value) : bool := 
  match v1, v2 with
    | const c1, const c2 => match c1, c2 with
        | cnstn a, cnstn a' => eqb a a'
        | Nil, Nil => true
        | _, _ => false
      end
    | eq e1, eq e2 => match e1, e2 with
        | PUBKEY g1 k1, PUBKEY g2 k2 => value_beq k1 k2
        | DH _ exp1 exp2, DH _ exp1' exp2' => ((value_beq exp1 exp1') && (value_beq exp2 exp2')) || ((value_beq exp1 exp2') && (value_beq exp2 exp1'))
        | _, _ => false
      end
    | prim p1, prim p2 => match p1, p2 with
        | ENC k1 m1, ENC k2 m2 => (value_beq k1 k2) && (value_beq m1 m2)
        | DEC k1 e1, DEC k2 e2 => (value_beq k1 k2) && (value_beq e1 e2)
        | AEAD_ENC k1 m1 ad1, AEAD_ENC k2 m2 ad2 => ((value_beq k1 k2) && (value_beq m1 m2)) && (value_beq ad1 ad2)
        | AEAD_DEC k1 e1 ad1, AEAD_DEC k2 e2 ad2 => ((value_beq k1 k2) && (value_beq e1 e2)) && (value_beq ad1 ad2)
        | PKE_ENC gk1 m1, PKE_ENC gk2 m2 => (value_beq gk1 gk2) && (value_beq m1 m2)
        | PKE_DEC k1 e1, PKE_DEC k2 e2 => (value_beq k1 k2) && (value_beq e1 e2)
        | HASH1 a1, HASH1 a2 => value_beq a1 a2
        | HASH2 a1 b1, HASH2 a2 b2 => (value_beq a1 a2) && (value_beq b1 b2)
        | HASH3 a1 b1 c1, HASH3 a2 b2 c2 => ((value_beq a1 a2) && (value_beq b1 b2)) && (value_beq c1 c2)
        | HASH4 a1 b1 c1 d1, HASH4 a2 b2 c2 d2 => ((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))
        | HASH5 a1 b1 c1 d1 e1, HASH5 a2 b2 c2 d2 e2 => (((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))) && (value_beq e1 e2)
        | MAC a1 b1, MAC a2 b2 => (value_beq a1 a2) && (value_beq b1 b2)
        | HKDF1 s1 k1 i1, HKDF1 s2 k2 i2 => ((value_beq s1 s2) && (value_beq k1 k2)) && (value_beq i1 i2)
        | HKDF2 s1 k1 i1, HKDF2 s2 k2 i2 => ((value_beq s1 s2) && (value_beq k1 k2)) && (value_beq i1 i2)
        | HKDF3 s1 k1 i1, HKDF3 s2 k2 i2 => ((value_beq s1 s2) && (value_beq k1 k2)) && (value_beq i1 i2)
        | HKDF4 s1 k1 i1, HKDF4 s2 k2 i2 => ((value_beq s1 s2) && (value_beq k1 k2)) && (value_beq i1 i2)
        | HKDF5 s1 k1 i1, HKDF5 s2 k2 i2 => ((value_beq s1 s2) && (value_beq k1 k2)) && (value_beq i1 i2)
        | PW_HASH1 a1, PW_HASH1 a2 => value_beq a1 a2
        | PW_HASH2 a1 b1, PW_HASH2 a2 b2 => (value_beq a1 a2) && (value_beq b1 b2)
        | PW_HASH3 a1 b1 c1, PW_HASH3 a2 b2 c2 => ((value_beq a1 a2) && (value_beq b1 b2)) && (value_beq c1 c2)
        | PW_HASH4 a1 b1 c1 d1, PW_HASH4 a2 b2 c2 d2 => ((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))
        | PW_HASH5 a1 b1 c1 d1 e1, PW_HASH5 a2 b2 c2 d2 e2 => (((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))) && (value_beq e1 e2)
        | SIGN k1 m1, SIGN k2 m2 => (value_beq k1 k2) && (value_beq m1 m2)
        | SIGNVERIF gk m s, SIGNVERIF gk' m' s' => ((value_beq gk gk') && (value_beq m m')) && (value_beq s s')
        | RINGSIGN ka1 gkb1 gkc1 m1, RINGSIGN ka2 gkb2 gkc2 m2 => ((value_beq ka1 ka2) && (value_beq gkb1 gkb2)) && (
          (value_beq gkc1 gkc2) && (value_beq m1 m2))
        | RINGSIGNVERIF gka1 gkb1 gkc1 m1 s1, RINGSIGNVERIF gka2 gkb2 gkc2 m2 s2 => 
          (((value_beq gka1 gka2) && (value_beq gkb1 gkb2)) && ((value_beq gkc1 gkc2) && (value_beq m1 m2))) && (value_beq s1 s2)
        | SHAMIR_SPLIT1 k1, SHAMIR_SPLIT1 k2 => value_beq k1 k2
        | SHAMIR_SPLIT2 k1, SHAMIR_SPLIT2 k2 => value_beq k1 k2
        | SHAMIR_SPLIT3 k1, SHAMIR_SPLIT3 k2 => value_beq k1 k2
        | SHAMIR_JOIN sa1 sb1, SHAMIR_JOIN sa2 sb2 => (value_beq sa1 sa2) && (value_beq sb1 sb2)
        | CONCAT2 a1 b1, CONCAT2 a2 b2 => (value_beq a1 a2) && (value_beq b1 b2)
        | CONCAT3 a1 b1 c1, CONCAT3 a2 b2 c2 => ((value_beq a1 a2) && (value_beq b1 b2)) && (value_beq c1 c2)
        | CONCAT4 a1 b1 c1 d1, CONCAT4 a2 b2 c2 d2 => ((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))
        | CONCAT5 a1 b1 c1 d1 e1, CONCAT5 a2 b2 c2 d2 e2 => (((value_beq a1 a2) && (value_beq b1 b2)) && ((value_beq c1 c2) && (value_beq d1 d2))) && (value_beq e1 e2)
        | SPLIT1 a1, SPLIT1 a2 => value_beq a1 a2
        | SPLIT2 a1, SPLIT2 a2 => value_beq a1 a2
        | SPLIT3 a1, SPLIT3 a2 => value_beq a1 a2
        | SPLIT4 a1, SPLIT4 a2 => value_beq a1 a2
        | SPLIT5 a1, SPLIT5 a2 => value_beq a1 a2
        | _, _ => false
      end
    | pass a, pass b => match a, b with
        | cnstn a, cnstn b => eqb a b
        | Nil, Nil => true
        | _ , _ => false
      end
    | default, default => true
    | _, _ => false
  end.

Fixpoint has_nested_value (main v: value) : bool :=
    match main with
    | default => false
    | const _ => value_beq v main
    | pass _ => value_beq v main
    | eq e => match e with
        | PUBKEY _ exp => has_nested_value exp v
        | DH _ exp1 exp2 => (has_nested_value exp1 v) || (has_nested_value exp2 v)
      end
    | prim p => match p with
        | ENC k m => (has_nested_value k v) || (has_nested_value m v)
        | DEC k c => (has_nested_value k v) || (has_nested_value c v)
        | AEAD_ENC k m ad => ((has_nested_value k v) || (has_nested_value m v)) || (has_nested_value ad v)
        | AEAD_DEC k c ad => ((has_nested_value k v) || (has_nested_value c v)) || (has_nested_value ad v)
        | PKE_ENC gk m => (has_nested_value gk v) || (has_nested_value m v)
        | PKE_DEC k m => (has_nested_value k v) || (has_nested_value m v)
        | HASH1 a => has_nested_value a v
        | HASH2 a b => (has_nested_value a v) || (has_nested_value b v)
        | HASH3 a b c => ((has_nested_value a v) || (has_nested_value b v)) || (has_nested_value c v)
        | HASH4 a b c d => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v))
        | HASH5 a b c d e => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v)) || (has_nested_value e v)
        | MAC a b => (has_nested_value a v) || (has_nested_value b v)
        | HKDF1 s k i => ((has_nested_value s v) || (has_nested_value k v)) || (has_nested_value i v)
        | HKDF2 s k i => ((has_nested_value s v) || (has_nested_value k v)) || (has_nested_value i v)
        | HKDF3 s k i => ((has_nested_value s v) || (has_nested_value k v)) || (has_nested_value i v)
        | HKDF4 s k i => ((has_nested_value s v) || (has_nested_value k v)) || (has_nested_value i v)
        | HKDF5 s k i => ((has_nested_value s v) || (has_nested_value k v)) || (has_nested_value i v)
        | PW_HASH1 a => has_nested_value a v
        | PW_HASH2 a b => (has_nested_value a v) || (has_nested_value b v)
        | PW_HASH3 a b c => ((has_nested_value a v) || (has_nested_value b v)) || (has_nested_value c v)
        | PW_HASH4 a b c d => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v))
        | PW_HASH5 a b c d e => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v)) || (has_nested_value e v)
        | SIGN k m => (has_nested_value k v) || (has_nested_value m v)
        | SIGNVERIF k m s => ((has_nested_value k v) || (has_nested_value m v)) || (has_nested_value s v)
        | RINGSIGN ka gkb gkc m => ((has_nested_value ka v) || (has_nested_value gkb v)) || ((has_nested_value gkc v) || (has_nested_value m v))
        | RINGSIGNVERIF ka gkb gkc m s => ((has_nested_value ka v) || (has_nested_value gkb v)) || ((has_nested_value gkc v) || (has_nested_value m v)) || (has_nested_value s v)
        | BLIND k m => (has_nested_value k v) || (has_nested_value m v)
        | UNBLIND k m s => ((has_nested_value k v) || (has_nested_value m v)) || (has_nested_value s v)  
        | SHAMIR_SPLIT1 k => has_nested_value k v
        | SHAMIR_SPLIT2 k => has_nested_value k v
        | SHAMIR_SPLIT3 k => has_nested_value k v
        | SHAMIR_JOIN sa sb => (has_nested_value sa v) || (has_nested_value sb v)
        | CONCAT2 a b => (has_nested_value a v) || (has_nested_value b v)
        | CONCAT3 a b c => ((has_nested_value a v) || (has_nested_value b v)) || (has_nested_value c v)
        | CONCAT4 a b c d => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v))
        | CONCAT5 a b c d e => ((has_nested_value a v) || (has_nested_value b v)) || ((has_nested_value c v) || (has_nested_value d v)) || (has_nested_value e v)
        | SPLIT1 a => has_nested_value a v
        | SPLIT2 a => has_nested_value a v
        | SPLIT3 a => has_nested_value a v
        | SPLIT4 a => has_nested_value a v
        | SPLIT5 a => has_nested_value a v
      end
  end.
Definition is_primitive (v: value): bool :=
  match v with
    | prim p => true
    | _ => false
  end.

Definition is_constant (v: value): bool :=
  match v with
    | const c => true
    | _ => false
  end.

Definition is_equation (v: value): bool :=
  match v with
    | eq e => true
    | _ => false
  end.

Fixpoint shallow_search (l: list value) (v: value) : bool :=
    match l with
    | [] => false
    | h :: t => match value_beq h v with
        | true => true
        | false => shallow_search t v
      end
  end.

Definition deep_search (l : list value) (v : value) := filter (fun x => has_nested_value x v) l.
Fixpoint remove_value_list (l: list value) (v: value) : list value :=
  match l with
      | [] => []
      | h :: t => match value_beq h v with 
          | true => t
          | false => [h] ++ (remove_value_list t v)
        end
    end.

Fixpoint merge_lists (l1 l2: list value) : list value :=
  match l1 with
      | [] => l2
      | h :: t => [h] ++ (merge_lists t (remove_value_list l2 h))
  end.

Inductive principal : Type :=
| PRINCIPAL : string -> list expression -> principal.

Inductive message : Type :=
| MSG : guard_status -> value -> message.

Inductive block : Type :=
| pblock : principal -> block
| mblock : message -> block.

Inductive state : Type :=
| STATE: list block -> state.


Fixpoint absorb_expression (l: list expression) : list value :=
  match l with
    | [] => []  
    | h :: t => match h with
        | EXP dec qual val ls => match qual, ls with
            | private, not_leaked => absorb_expression t
            | _, _ => [val] ++ absorb_expression t
          end
      end
  end.

Fixpoint has_password (v: value) : list value :=
  match v with
  | prim p => match p with
      | CONCAT2 a b => has_password a ++ has_password b
      | CONCAT3 a b c => has_password a ++ has_password b ++ has_password c
      | CONCAT4 a b c d => has_password a ++ has_password b ++ has_password c ++ has_password d
      | CONCAT5 a b c d e => has_password a ++ has_password b ++ has_password c ++ has_password d ++ has_password e
      | SPLIT1 a => has_password a
      | SPLIT2 a => has_password a
      | SPLIT3 a => has_password a
      | SPLIT4 a => has_password a
      | SPLIT5 a => has_password a
      | PW_HASH1 a => []
      | PW_HASH2 a b => []
      | PW_HASH3 a b c => []
      | PW_HASH4 a b c d => []
      | PW_HASH5 a b c d e => []
      | HASH1 a => has_password a
      | HASH2 a b => has_password a ++ has_password b
      | HASH3 a b c => has_password a ++ has_password b ++ has_password c
      | HASH4 a b c d => has_password a ++ has_password b ++ has_password c ++ has_password d
      | HASH5 a b c d e => has_password a ++ has_password b ++ has_password c ++ has_password d ++ has_password e
      | HKDF1 salt ikm info => has_password salt ++ has_password ikm ++ has_password info
      | HKDF2 salt ikm info => has_password salt ++ has_password ikm ++ has_password info
      | HKDF3 salt ikm info => has_password salt ++ has_password ikm ++ has_password info
      | HKDF4 salt ikm info => has_password salt ++ has_password ikm ++ has_password info
      | HKDF5 salt ikm info => has_password salt ++ has_password ikm ++ has_password info
      | AEAD_ENC k m ad => has_password k ++ has_password ad
      | AEAD_DEC k c ad => has_password k ++ has_password c ++  has_password ad
      | ENC k m => has_password k
      | DEC k c => has_password k ++ has_password c
      | MAC k m => has_password k
      | SIGN k m => has_password k
      | SIGNVERIF k m s => has_password k ++ has_password m ++ has_password s 
      | PKE_ENC gk m => has_password gk
      | PKE_DEC k c => has_password k ++ has_password c
      | SHAMIR_SPLIT1 k => has_password k
      | SHAMIR_SPLIT2 k => has_password k
      | SHAMIR_SPLIT3 k => has_password k
      | SHAMIR_JOIN sa sb => has_password sa ++ has_password sb
      | RINGSIGN ka gkb gkc m => has_password ka ++ has_password gkb ++ has_password gkc
      | RINGSIGNVERIF gka gkb gkc m s => has_password gka ++ has_password gkb ++ has_password gkc ++ has_password m ++ has_password s
      | BLIND k m => has_password k
      | UNBLIND k m s => has_password k ++ has_password m ++ has_password s
    end
  | eq e => match e with
      | PUBKEY _ exp => has_password exp
      | DH _ exp1 exp2 => has_password exp1 ++ has_password exp2
    end
  | const c => match c with
      | Nil => []
      | cnstn c => []
    end
    | pass a => [v]
    | default => []
end.

Fixpoint absorb_passwords_expression (l: list expression) : list value :=
  match l with
    | [] => []  
    | h :: t => match h with
        | EXP dec qual val ls => has_password val ++ absorb_passwords_expression t
      end
  end.

Fixpoint absorb_principal (p: principal) : list value :=
  match p with
  | PRINCIPAL _ pk => merge_lists (absorb_expression pk) (absorb_passwords_expression pk)
end.

Fixpoint absorb_message (m: message) : value :=
  match m with
  | MSG _ val => val
end.

Fixpoint absorb_block (b: block) : list value :=
  match b with
    | pblock p => absorb_principal p
    | mblock m => [absorb_message m]
end.

Fixpoint init_attacker (l: list block) : list value := 
  match l with
    | [] => []
    | h :: t => absorb_block h ++ init_attacker t
end.

Fixpoint gather_principal_expressions (l: list block) (pname: string) : list expression :=
  match l with
    | [] => []
    | h :: t => match h with
      | mblock _ => gather_principal_expressions t pname
      | pblock pb => match pb with
          | PRINCIPAL hpname hplist => match eqb pname hpname with
                  | true => hplist ++ gather_principal_expressions t pname
                  | false => gather_principal_expressions t pname
              end
          end
      end
  end.

Fixpoint gather_principals (pnames: list string) (l: list block) : list principal :=
  match pnames with 
    | [] => []
    | p1 :: r => [PRINCIPAL p1 (gather_principal_expressions l p1)] ++ gather_principals r l
  end.

Fixpoint get_values_expression_list (l: list expression) : list value :=
  match l with
    | [] => []
    | h :: t => match h with
      | EXP _ _ v _  => [v] ++ get_values_expression_list t
      end
  end.

Fixpoint gather_principal_values (l: list principal) : list (list value) :=
  match l with
    | [] => []
    | h :: t => match h with
        | PRINCIPAL pname plist => [get_values_expression_list plist] ++ gather_principal_values t
      end
  end.

Definition rewrite_diff (old new: value) : value :=
  match old, new with
    | const c1, const c2 => match value_beq old new with
        | true => old
        | false => new
      end
    | pass a1, pass a2 => match value_beq old new with
        | true => old
        | false => new
      end
    | prim p1, prim p2 => match p1, p2 with
        | ENC k1 m1, ENC k2 m2 => match value_beq k1 k2, value_beq m1 m2 with
            | true, true => old
            | false, true => prim(ENC k2 m1)
            | true, false => prim(ENC k1 m2)
            | false, false => new
          end
        | DEC k1 c1, DEC k2 c2 => match value_beq k1 k2, value_beq c1 c2 with
            | true, true => old
            | false, true => prim(DEC k2 c1)
            | true, false => prim(DEC k1 c2)
            | false, false => new
          end
        | AEAD_ENC k1 m1 ad1, AEAD_ENC k2 m2 ad2 =>
           match value_beq k1 k2, value_beq m1 m2, value_beq ad1 ad2 with
            | true, true, true => old
            | false, true, true => prim(AEAD_ENC k2 m1 ad1)
            | true, false, true => prim(AEAD_ENC k1 m2 ad1)
            | true, true, false => prim(AEAD_ENC k1 m1 ad2)
            | true, false, false => prim(AEAD_ENC k1 m2 ad2)
            | false, true, false => prim(AEAD_ENC k2 m1 ad1)
            | false, false, true => prim(AEAD_ENC k2 m2 ad1)
            | false, false, false => new
          end
        | AEAD_DEC k1 c1 ad1, AEAD_DEC k2 c2 ad2 =>
           match value_beq k1 k2, value_beq c1 c2, value_beq ad1 ad2 with
            | true, true, true => old
            | false, true, true => prim(AEAD_DEC k2 c1 ad1)
            | true, false, true => prim(AEAD_DEC k1 c2 ad1)
            | true, true, false => prim(AEAD_DEC k1 c1 ad2)
            | true, false, false => prim(AEAD_DEC k1 c2 ad2)
            | false, true, false => prim(AEAD_DEC k2 c1 ad1)
            | false, false, true => prim(AEAD_DEC k2 c2 ad1)
            | false, false, false => new
          end
      | PKE_ENC gk1 m1, ENC gk2 m2 => match value_beq gk1 gk2, value_beq m1 m2 with
          | true, true => old
          | false, true => prim(PKE_ENC gk2 m1)
          | true, false => prim(PKE_ENC gk1 m2)
          | false, false => new
        end
      | PKE_DEC k1 c1, PKE_DEC k2 c2 => match value_beq k1 k2, value_beq c1 c2 with
          | true, true => old
          | false, true => prim(PKE_DEC k2 c1)
          | true, false => prim(PKE_DEC k1 c2)
          | false, false => new
        end
      | HASH1 a1, HASH1 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | HASH2 a1 b1, HASH2 a2 b2 => match value_beq a1 a2, value_beq b1 b2 with
          | true, true => old
          | false, true => prim(HASH2 a2 b1)
          | true, false => prim(HASH2 a1 b2)
          | false, false => new
        end
      | HASH3 a1 b1 c1, HASH3 a2 b2 c2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2 with
         | true, true, true => old
         | false, true, true => prim(HASH3 a2 b1 c1)
         | true, false, true => prim(HASH3 a1 b2 c1)
         | true, true, false => prim(HASH3 a1 b1 c2)
         | true, false, false => prim(HASH3 a1 b2 c2)
         | false, true, false => prim(HASH3 a2 b1 c1)
         | false, false, true => prim(HASH3 a2 b2 c1)
         | false, false, false => new
       end
      | HASH4 a1 b1 c1 d1, HASH4 a2 b2 c2 d2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2 with
         | true, true, true, true => old
         | false, true, true, true => prim(HASH4 a2 b1 c1 d1)
         | true, false, true, true => prim(HASH4 a1 b2 c1 d1)
         | true, true, false, true => prim(HASH4 a1 b1 c2 d1)
         | true, true, true, false => prim(HASH4 a1 b1 c1 d2)
         | false, false, true, true => prim(HASH4 a2 b2 c1 d1)
         | false, true, false, true => prim(HASH4 a2 b1 c2 d1)
         | false, true, true, false => prim(HASH4 a2 b1 c1 d2)
         | true, false, false, true => prim(HASH4 a1 b2 c2 d1)
         | true, false, true, false => prim(HASH4 a1 b2 c1 d2)
         | true, true, false, false => prim(HASH4 a1 b1 c2 d2)
         | true, false, false, false => prim(HASH4 a1 b2 c2 d2)
         | false, true, false, false => prim(HASH4 a2 b1 c2 d2)
         | false, false, true, false => prim(HASH4 a2 b2 c1 d2)
         | false, false, false, true => prim(HASH4 a2 b2 c2 d1)
         | false, false, false, false => new
       end
      | HASH5 a1 b1 c1 d1 e1, HASH5 a2 b2 c2 d2 e2=>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2, value_beq e1 e2 with
         | true, true, true, true, true => old
         | false, true, true, true, true => prim(HASH5 a2 b1 c1 d1 e1)
         | true, false, true, true, true => prim(HASH5 a1 b2 c1 d1 e1)
         | true, true, false, true, true => prim(HASH5 a1 b1 c2 d1 e1)
         | true, true, true, false, true => prim(HASH5 a1 b1 c1 d2 e1)
         | true, true, true, true, false => prim(HASH5 a1 b1 c1 d1 e2)
         | false, false, true, true, true => prim(HASH5 a2 b2 c1 d1 e1)
         | false, true, false, true, true => prim(HASH5 a2 b1 c2 d1 e1)
         | false, true, true, false, true => prim(HASH5 a2 b1 c1 d2 e1)
         | false, true, true, true, false => prim(HASH5 a2 b1 c1 d1 e2)
         | true, false, false, true, true => prim(HASH5 a1 b2 c2 d1 e1)
         | true, false, true, false, true => prim(HASH5 a1 b2 c1 d2 e1)
         | true, false, true, true, false => prim(HASH5 a1 b2 c1 d1 e2)
         | true, true, false, false, true => prim(HASH5 a1 b1 c2 d2 e1)
         | true, true, false, true, false => prim(HASH5 a1 b1 c2 d1 e2)
         | true, true, true, false, false => prim(HASH5 a1 b1 c1 d2 e2)
         | true, true, false, false, false => prim(HASH5 a1 b1 c2 d2 e2)
         | true, false, true, false, false => prim(HASH5 a1 b2 c1 d2 e2)
         | true, false, false, true, false => prim(HASH5 a1 b2 c2 d1 e2)
         | true, false, false, false, true => prim(HASH5 a1 b2 c2 d2 e1)
         | false, true, true, false, false => prim(HASH5 a2 b1 c1 d2 e2)
         | false, true, false, true, false => prim(HASH5 a2 b1 c2 d1 e2)
         | false, true, false, false, true => prim(HASH5 a2 b1 c2 d2 e1)
         | false, false, true, true, false => prim(HASH5 a2 b2 c1 d1 e2)
         | false, false, true, false, true => prim(HASH5 a2 b2 c1 d2 e1)
         | false, false, false, true, true => prim(HASH5 a2 b2 c2 d1 e1)
         | true, false, false, false, false => prim(HASH5 a1 b2 c2 d2 e2)
         | false, true, false, false, false => prim(HASH5 a2 b1 c2 d2 e2)
         | false, false, true, false, false => prim(HASH5 a2 b2 c1 d2 e2)
         | false, false, false, true, false => prim(HASH5 a2 b2 c2 d1 e2)
         | false, false, false, false, true => prim(HASH5 a2 b2 c2 d2 e1)
         | false, false, false, false, false => new
       end
        | MAC k1 m1, MAC k2 m2 => match value_beq k1 k2, value_beq m1 m2 with
            | true, true => old
            | false, true => prim(MAC k2 m1)
            | true, false => prim(MAC k1 m2)
            | false, false => new
          end
        | HKDF1 salt1 ikm1 info1, HKDF1 salt2 ikm2 info2 =>
          match value_beq salt1 salt2, value_beq ikm1 ikm2, value_beq info1 info2 with
           | true, true, true => old
           | false, true, true => prim(HKDF1 salt2 ikm1 info1)
           | true, false, true => prim(HKDF1 salt1 ikm2 info1)
           | true, true, false => prim(HKDF1 salt1 ikm1 info2)
           | true, false, false => prim(HKDF1 salt1 ikm2 info2)
           | false, true, false => prim(HKDF1 salt2 ikm1 info1)
           | false, false, true => prim(HKDF1 salt2 ikm2 info1)
           | false, false, false => new
         end
        | HKDF2 salt1 ikm1 info1, HKDF2 salt2 ikm2 info2 =>
          match value_beq salt1 salt2, value_beq ikm1 ikm2, value_beq info1 info2 with
           | true, true, true => old
           | false, true, true => prim(HKDF2 salt2 ikm1 info1)
           | true, false, true => prim(HKDF2 salt1 ikm2 info1)
           | true, true, false => prim(HKDF2 salt1 ikm1 info2)
           | true, false, false => prim(HKDF2 salt1 ikm2 info2)
           | false, true, false => prim(HKDF2 salt2 ikm1 info1)
           | false, false, true => prim(HKDF2 salt2 ikm2 info1)
           | false, false, false => new
         end
        | HKDF3 salt1 ikm1 info1, HKDF3 salt2 ikm2 info2 =>
          match value_beq salt1 salt2, value_beq ikm1 ikm2, value_beq info1 info2 with
           | true, true, true => old
           | false, true, true => prim(HKDF3 salt2 ikm1 info1)
           | true, false, true => prim(HKDF3 salt1 ikm2 info1)
           | true, true, false => prim(HKDF3 salt1 ikm1 info2)
           | true, false, false => prim(HKDF3 salt1 ikm2 info2)
           | false, true, false => prim(HKDF3 salt2 ikm1 info1)
           | false, false, true => prim(HKDF3 salt2 ikm2 info1)
           | false, false, false => new
         end
        | HKDF4 salt1 ikm1 info1, HKDF4 salt2 ikm2 info2 =>
          match value_beq salt1 salt2, value_beq ikm1 ikm2, value_beq info1 info2 with
           | true, true, true => old
           | false, true, true => prim(HKDF4 salt2 ikm1 info1)
           | true, false, true => prim(HKDF4 salt1 ikm2 info1)
           | true, true, false => prim(HKDF4 salt1 ikm1 info2)
           | true, false, false => prim(HKDF4 salt1 ikm2 info2)
           | false, true, false => prim(HKDF4 salt2 ikm1 info1)
           | false, false, true => prim(HKDF4 salt2 ikm2 info1)
           | false, false, false => new
         end
        | HKDF5 salt1 ikm1 info1, HKDF5 salt2 ikm2 info2 =>
          match value_beq salt1 salt2, value_beq ikm1 ikm2, value_beq info1 info2 with
           | true, true, true => old
           | false, true, true => prim(HKDF5 salt2 ikm1 info1)
           | true, false, true => prim(HKDF5 salt1 ikm2 info1)
           | true, true, false => prim(HKDF5 salt1 ikm1 info2)
           | true, false, false => prim(HKDF5 salt1 ikm2 info2)
           | false, true, false => prim(HKDF5 salt2 ikm1 info1)
           | false, false, true => prim(HKDF5 salt2 ikm2 info1)
           | false, false, false => new
         end
      | PW_HASH1 a1, PW_HASH1 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | PW_HASH2 a1 b1, PW_HASH2 a2 b2 => match value_beq a1 a2, value_beq b1 b2 with
          | true, true => old
          | false, true => prim(PW_HASH2 a2 b1)
          | true, false => prim(PW_HASH2 a1 b2)
          | false, false => new
        end
      | PW_HASH3 a1 b1 c1, PW_HASH3 a2 b2 c2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2 with
         | true, true, true => old
         | false, true, true => prim(PW_HASH3 a2 b1 c1)
         | true, false, true => prim(PW_HASH3 a1 b2 c1)
         | true, true, false => prim(PW_HASH3 a1 b1 c2)
         | true, false, false => prim(PW_HASH3 a1 b2 c2)
         | false, true, false => prim(PW_HASH3 a2 b1 c1)
         | false, false, true => prim(PW_HASH3 a2 b2 c1)
         | false, false, false => new
       end
      | PW_HASH4 a1 b1 c1 d1, PW_HASH4 a2 b2 c2 d2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2 with
         | true, true, true, true => old
         | false, true, true, true => prim(PW_HASH4 a2 b1 c1 d1)
         | true, false, true, true => prim(PW_HASH4 a1 b2 c1 d1)
         | true, true, false, true => prim(PW_HASH4 a1 b1 c2 d1)
         | true, true, true, false => prim(PW_HASH4 a1 b1 c1 d2)
         | false, false, true, true => prim(PW_HASH4 a2 b2 c1 d1)
         | false, true, false, true => prim(PW_HASH4 a2 b1 c2 d1)
         | false, true, true, false => prim(PW_HASH4 a2 b1 c1 d2)
         | true, false, false, true => prim(PW_HASH4 a1 b2 c2 d1)
         | true, false, true, false => prim(PW_HASH4 a1 b2 c1 d2)
         | true, true, false, false => prim(PW_HASH4 a1 b1 c2 d2)
         | true, false, false, false => prim(PW_HASH4 a1 b2 c2 d2)
         | false, true, false, false => prim(PW_HASH4 a2 b1 c2 d2)
         | false, false, true, false => prim(PW_HASH4 a2 b2 c1 d2)
         | false, false, false, true => prim(PW_HASH4 a2 b2 c2 d1)
         | false, false, false, false => new
       end
      | PW_HASH5 a1 b1 c1 d1 e1, PW_HASH5 a2 b2 c2 d2 e2=>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2, value_beq e1 e2 with
         | true, true, true, true, true => old
         | false, true, true, true, true => prim(PW_HASH5 a2 b1 c1 d1 e1)
         | true, false, true, true, true => prim(PW_HASH5 a1 b2 c1 d1 e1)
         | true, true, false, true, true => prim(PW_HASH5 a1 b1 c2 d1 e1)
         | true, true, true, false, true => prim(PW_HASH5 a1 b1 c1 d2 e1)
         | true, true, true, true, false => prim(PW_HASH5 a1 b1 c1 d1 e2)
         | false, false, true, true, true => prim(PW_HASH5 a2 b2 c1 d1 e1)
         | false, true, false, true, true => prim(PW_HASH5 a2 b1 c2 d1 e1)
         | false, true, true, false, true => prim(PW_HASH5 a2 b1 c1 d2 e1)
         | false, true, true, true, false => prim(PW_HASH5 a2 b1 c1 d1 e2)
         | true, false, false, true, true => prim(PW_HASH5 a1 b2 c2 d1 e1)
         | true, false, true, false, true => prim(PW_HASH5 a1 b2 c1 d2 e1)
         | true, false, true, true, false => prim(PW_HASH5 a1 b2 c1 d1 e2)
         | true, true, false, false, true => prim(PW_HASH5 a1 b1 c2 d2 e1)
         | true, true, false, true, false => prim(PW_HASH5 a1 b1 c2 d1 e2)
         | true, true, true, false, false => prim(PW_HASH5 a1 b1 c1 d2 e2)
         | true, true, false, false, false => prim(PW_HASH5 a1 b1 c2 d2 e2)
         | true, false, true, false, false => prim(PW_HASH5 a1 b2 c1 d2 e2)
         | true, false, false, true, false => prim(PW_HASH5 a1 b2 c2 d1 e2)
         | true, false, false, false, true => prim(PW_HASH5 a1 b2 c2 d2 e1)
         | false, true, true, false, false => prim(PW_HASH5 a2 b1 c1 d2 e2)
         | false, true, false, true, false => prim(PW_HASH5 a2 b1 c2 d1 e2)
         | false, true, false, false, true => prim(PW_HASH5 a2 b1 c2 d2 e1)
         | false, false, true, true, false => prim(PW_HASH5 a2 b2 c1 d1 e2)
         | false, false, true, false, true => prim(PW_HASH5 a2 b2 c1 d2 e1)
         | false, false, false, true, true => prim(PW_HASH5 a2 b2 c2 d1 e1)
         | true, false, false, false, false => prim(PW_HASH5 a1 b2 c2 d2 e2)
         | false, true, false, false, false => prim(PW_HASH5 a2 b1 c2 d2 e2)
         | false, false, true, false, false => prim(PW_HASH5 a2 b2 c1 d2 e2)
         | false, false, false, true, false => prim(PW_HASH5 a2 b2 c2 d1 e2)
         | false, false, false, false, true => prim(PW_HASH5 a2 b2 c2 d2 e1)
         | false, false, false, false, false => new
       end
      | SIGN k1 m1, SIGN k2 m2 => match value_beq k1 k2, value_beq m1 m2 with
          | true, true => old
          | false, true => prim(SIGN k2 m1)
          | true, false => prim(SIGN k1 m2)
          | false, false => new
        end
      | SIGNVERIF k1 m1 s1, SIGNVERIF k2 m2 s2 =>
         match value_beq k1 k2, value_beq m1 m2, value_beq s1 s2 with
          | true, true, true => old
          | false, true, true => prim(SIGNVERIF k2 m1 s1)
          | true, false, true => prim(SIGNVERIF k1 m2 s1)
          | true, true, false => prim(SIGNVERIF k1 m1 s2)
          | true, false, false => prim(SIGNVERIF k1 m2 s2)
          | false, true, false => prim(SIGNVERIF k2 m1 s1)
          | false, false, true => prim(SIGNVERIF k2 m2 s1)
          | false, false, false => new
        end
      | RINGSIGN ka1 gkb1 gkc1 m1, RINGSIGN ka2 gkb2 gkc2 m2 =>
        match value_beq ka1 ka2, value_beq gkb1 gkb2, value_beq gkc1 gkc2, value_beq m1 m2 with
          | true, true, true, true => old
          | false, true, true, true => prim(RINGSIGN ka2 gkb1 gkc1 m1)
          | true, false, true, true => prim(RINGSIGN ka1 gkb2 gkc1 m1)
          | true, true, false, true => prim(RINGSIGN ka1 gkb1 gkc2 m1)
          | true, true, true, false => prim(RINGSIGN ka1 gkb1 gkc1 m2)
          | false, false, true, true => prim(RINGSIGN ka2 gkb2 gkc1 m1)
          | false, true, false, true => prim(RINGSIGN ka2 gkb1 gkc2 m1)
          | false, true, true, false => prim(RINGSIGN ka2 gkb1 gkc1 m2)
          | true, false, false, true => prim(RINGSIGN ka1 gkb2 gkc2 m1)
          | true, false, true, false => prim(RINGSIGN ka1 gkb2 gkc1 m2)
          | true, true, false, false => prim(RINGSIGN ka1 gkb1 gkc2 m2)
          | true, false, false, false => prim(RINGSIGN ka1 gkb2 gkc2 m2)
          | false, true, false, false => prim(RINGSIGN ka2 gkb1 gkc2 m2)
          | false, false, true, false => prim(RINGSIGN ka2 gkb2 gkc1 m2)
          | false, false, false, true => prim(RINGSIGN ka2 gkb2 gkc2 m1)
          | false, false, false, false => new
        end
      | RINGSIGNVERIF gka1 gkb1 gkc1 m1 s1, RINGSIGNVERIF gka2 gkb2 gkc2 m2 s2=>
        match value_beq gka1 gka2, value_beq gkb1 gkb2, value_beq gkc1 gkc2, value_beq m1 m2, value_beq s1 s2 with
          | true, true, true, true, true => old
          | false, true, true, true, true => prim(RINGSIGNVERIF gka2 gkb1 gkc1 m1 s1)
          | true, false, true, true, true => prim(RINGSIGNVERIF gka1 gkb2 gkc1 m1 s1)
          | true, true, false, true, true => prim(RINGSIGNVERIF gka1 gkb1 gkc2 m1 s1)
          | true, true, true, false, true => prim(RINGSIGNVERIF gka1 gkb1 gkc1 m2 s1)
          | true, true, true, true, false => prim(RINGSIGNVERIF gka1 gkb1 gkc1 m1 s2)
          | false, false, true, true, true => prim(RINGSIGNVERIF gka2 gkb2 gkc1 m1 s1)
          | false, true, false, true, true => prim(RINGSIGNVERIF gka2 gkb1 gkc2 m1 s1)
          | false, true, true, false, true => prim(RINGSIGNVERIF gka2 gkb1 gkc1 m2 s1)
          | false, true, true, true, false => prim(RINGSIGNVERIF gka2 gkb1 gkc1 m1 s2)
          | true, false, false, true, true => prim(RINGSIGNVERIF gka1 gkb2 gkc2 m1 s1)
          | true, false, true, false, true => prim(RINGSIGNVERIF gka1 gkb2 gkc1 m2 s1)
          | true, false, true, true, false => prim(RINGSIGNVERIF gka1 gkb2 gkc1 m1 s2)
          | true, true, false, false, true => prim(RINGSIGNVERIF gka1 gkb1 gkc2 m2 s1)
          | true, true, false, true, false => prim(RINGSIGNVERIF gka1 gkb1 gkc2 m1 s2)
          | true, true, true, false, false => prim(RINGSIGNVERIF gka1 gkb1 gkc1 m2 s2)
          | true, true, false, false, false => prim(RINGSIGNVERIF gka1 gkb1 gkc2 m2 s2)
          | true, false, true, false, false => prim(RINGSIGNVERIF gka1 gkb2 gkc1 m2 s2)
          | true, false, false, true, false => prim(RINGSIGNVERIF gka1 gkb2 gkc2 m1 s2)
          | true, false, false, false, true => prim(RINGSIGNVERIF gka1 gkb2 gkc2 m2 s1)
          | false, true, true, false, false => prim(RINGSIGNVERIF gka2 gkb1 gkc1 m2 s2)
          | false, true, false, true, false => prim(RINGSIGNVERIF gka2 gkb1 gkc2 m1 s2)
          | false, true, false, false, true => prim(RINGSIGNVERIF gka2 gkb1 gkc2 m2 s1)
          | false, false, true, true, false => prim(RINGSIGNVERIF gka2 gkb2 gkc1 m1 s2)
          | false, false, true, false, true => prim(RINGSIGNVERIF gka2 gkb2 gkc1 m2 s1)
          | false, false, false, true, true => prim(RINGSIGNVERIF gka2 gkb2 gkc2 m1 s1)
          | true, false, false, false, false => prim(RINGSIGNVERIF gka1 gkb2 gkc2 m2 s2)
          | false, true, false, false, false => prim(RINGSIGNVERIF gka2 gkb1 gkc2 m2 s2)
          | false, false, true, false, false => prim(RINGSIGNVERIF gka2 gkb2 gkc1 m2 s2)
          | false, false, false, true, false => prim(RINGSIGNVERIF gka2 gkb2 gkc2 m1 s2)
          | false, false, false, false, true => prim(RINGSIGNVERIF gka2 gkb2 gkc2 m2 s1)
          | false, false, false, false, false => new
        end
      | BLIND k1 m1, BLIND k2 m2 => match value_beq k1 k2, value_beq m1 m2 with
          | true, true => old
          | false, true => prim(BLIND k2 m1)
          | true, false => prim(BLIND k1 m2)
          | false, false => new
        end
      | UNBLIND k1 m1 s1, UNBLIND k2 m2 s2 =>
        match value_beq k1 k2, value_beq m1 m2, value_beq s1 s2 with
          | true, true, true => old
          | false, true, true => prim(UNBLIND k2 m1 s1)
          | true, false, true => prim(UNBLIND k1 m2 s1)
          | true, true, false => prim(UNBLIND k1 m1 s2)
          | true, false, false => prim(UNBLIND k1 m2 s2)
          | false, true, false => prim(UNBLIND k2 m1 s1)
          | false, false, true => prim(UNBLIND k2 m2 s1)
          | false, false, false => new
        end
      | SHAMIR_SPLIT1 a1, SHAMIR_SPLIT1 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SHAMIR_SPLIT2 a1, SHAMIR_SPLIT2 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SHAMIR_SPLIT3 a1, SHAMIR_SPLIT3 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SHAMIR_JOIN sa1 sb1, SHAMIR_JOIN sa2 sb2 => match value_beq sa1 sa2, value_beq sb1 sb2 with
          | true, true => old
          | false, true => prim(SHAMIR_JOIN sa2 sb1)
          | true, false => prim(SHAMIR_JOIN sa1 sb2)
          | false, false => new
        end
      | CONCAT2 a1 b1, CONCAT2 a2 b2 => match value_beq a1 a2, value_beq b1 b2 with
          | true, true => old
          | false, true => prim(CONCAT2 a2 b1)
          | true, false => prim(CONCAT2 a1 b2)
          | false, false => new
        end
      | CONCAT3 a1 b1 c1, CONCAT3 a2 b2 c2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2 with
          | true, true, true => old
          | false, true, true => prim(CONCAT3 a2 b1 c1)
          | true, false, true => prim(CONCAT3 a1 b2 c1)
          | true, true, false => prim(CONCAT3 a1 b1 c2)
          | true, false, false => prim(CONCAT3 a1 b2 c2)
          | false, true, false => prim(CONCAT3 a2 b1 c1)
          | false, false, true => prim(CONCAT3 a2 b2 c1)
          | false, false, false => new
        end
      | CONCAT4 a1 b1 c1 d1, CONCAT4 a2 b2 c2 d2 =>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2 with
          | true, true, true, true => old
          | false, true, true, true => prim(CONCAT4 a2 b1 c1 d1)
          | true, false, true, true => prim(CONCAT4 a1 b2 c1 d1)
          | true, true, false, true => prim(CONCAT4 a1 b1 c2 d1)
          | true, true, true, false => prim(CONCAT4 a1 b1 c1 d2)
          | false, false, true, true => prim(CONCAT4 a2 b2 c1 d1)
          | false, true, false, true => prim(CONCAT4 a2 b1 c2 d1)
          | false, true, true, false => prim(CONCAT4 a2 b1 c1 d2)
          | true, false, false, true => prim(CONCAT4 a1 b2 c2 d1)
          | true, false, true, false => prim(CONCAT4 a1 b2 c1 d2)
          | true, true, false, false => prim(CONCAT4 a1 b1 c2 d2)
          | true, false, false, false => prim(CONCAT4 a1 b2 c2 d2)
          | false, true, false, false => prim(CONCAT4 a2 b1 c2 d2)
          | false, false, true, false => prim(CONCAT4 a2 b2 c1 d2)
          | false, false, false, true => prim(CONCAT4 a2 b2 c2 d1)
          | false, false, false, false => new
        end
      | CONCAT5 a1 b1 c1 d1 e1, CONCAT5 a2 b2 c2 d2 e2=>
        match value_beq a1 a2, value_beq b1 b2, value_beq c1 c2, value_beq d1 d2, value_beq e1 e2 with
          | true, true, true, true, true => old
          | false, true, true, true, true => prim(CONCAT5 a2 b1 c1 d1 e1)
          | true, false, true, true, true => prim(CONCAT5 a1 b2 c1 d1 e1)
          | true, true, false, true, true => prim(CONCAT5 a1 b1 c2 d1 e1)
          | true, true, true, false, true => prim(CONCAT5 a1 b1 c1 d2 e1)
          | true, true, true, true, false => prim(CONCAT5 a1 b1 c1 d1 e2)
          | false, false, true, true, true => prim(CONCAT5 a2 b2 c1 d1 e1)
          | false, true, false, true, true => prim(CONCAT5 a2 b1 c2 d1 e1)
          | false, true, true, false, true => prim(CONCAT5 a2 b1 c1 d2 e1)
          | false, true, true, true, false => prim(CONCAT5 a2 b1 c1 d1 e2)
          | true, false, false, true, true => prim(CONCAT5 a1 b2 c2 d1 e1)
          | true, false, true, false, true => prim(CONCAT5 a1 b2 c1 d2 e1)
          | true, false, true, true, false => prim(CONCAT5 a1 b2 c1 d1 e2)
          | true, true, false, false, true => prim(CONCAT5 a1 b1 c2 d2 e1)
          | true, true, false, true, false => prim(CONCAT5 a1 b1 c2 d1 e2)
          | true, true, true, false, false => prim(CONCAT5 a1 b1 c1 d2 e2)
          | true, true, false, false, false => prim(CONCAT5 a1 b1 c2 d2 e2)
          | true, false, true, false, false => prim(CONCAT5 a1 b2 c1 d2 e2)
          | true, false, false, true, false => prim(CONCAT5 a1 b2 c2 d1 e2)
          | true, false, false, false, true => prim(CONCAT5 a1 b2 c2 d2 e1)
          | false, true, true, false, false => prim(CONCAT5 a2 b1 c1 d2 e2)
          | false, true, false, true, false => prim(CONCAT5 a2 b1 c2 d1 e2)
          | false, true, false, false, true => prim(CONCAT5 a2 b1 c2 d2 e1)
          | false, false, true, true, false => prim(CONCAT5 a2 b2 c1 d1 e2)
          | false, false, true, false, true => prim(CONCAT5 a2 b2 c1 d2 e1)
          | false, false, false, true, true => prim(CONCAT5 a2 b2 c2 d1 e1)
          | true, false, false, false, false => prim(CONCAT5 a1 b2 c2 d2 e2)
          | false, true, false, false, false => prim(CONCAT5 a2 b1 c2 d2 e2)
          | false, false, true, false, false => prim(CONCAT5 a2 b2 c1 d2 e2)
          | false, false, false, true, false => prim(CONCAT5 a2 b2 c2 d1 e2)
          | false, false, false, false, true => prim(CONCAT5 a2 b2 c2 d2 e1)
          | false, false, false, false, false => new
        end
      | SPLIT1 a1, SPLIT1 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SPLIT2 a1, SPLIT2 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SPLIT3 a1, SPLIT3 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SPLIT4 a1, SPLIT4 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | SPLIT5 a1, SPLIT5 a2 => match value_beq a1 a2 with
          | true => old
          | false => new
        end
      | _ , _ => new
    end
  | eq e1, eq e2 => match e1, e2 with
      | PUBKEY _ exp1, PUBKEY _ exp2 => match value_beq exp1 exp2 with
          | true => old
          | false => new
        end
      | DH _ expa1 expb1, DH _ expa2 expb2 => match value_beq expa1 expa2, value_beq expb1 expb2 with
          | true, true => old
          | true, false => eq(DH G expa1 expb2)
          | false, true => eq(DH G expa2 expb1)
          | false, false => new
        end
      | _ , _ => new
    end   
  | _, _ => new  
end.
      

Fixpoint apply_rewrites (l: list value) (v: value) : value := 
  match v with
      | default => default
      | const c => v
      | pass a => v
      | eq e => match e with
          | PUBKEY _ exp => eq(PUBKEY G (apply_rewrites l exp))
          | DH _ exp1 exp2 => eq(DH G (apply_rewrites l exp1) (apply_rewrites l exp2))
        end
      | prim p => match p with
          | ENC k m => prim(ENC (apply_rewrites l k) (apply_rewrites l m))
          | DEC k c => match c with
              | prim p' => match p' with
                  | ENC k' m => match value_beq k k' with    
                      | true => m
                      | false => prim(DEC (apply_rewrites l k) (prim(ENC (apply_rewrites l k) m)))
                  end
                  | _ => prim(DEC (apply_rewrites l k) (apply_rewrites l c))
                end
              | _ => prim(DEC (apply_rewrites l k) (apply_rewrites l c)) 
            end
          | AEAD_ENC k m ad => prim(AEAD_ENC (apply_rewrites l k) (apply_rewrites l m) (apply_rewrites l ad))
          | AEAD_DEC k c ad => match c with
              | prim p' => match p' with
                  | AEAD_ENC k' m ad' => match value_beq k k', value_beq ad ad' with
                      | true, true => m
                      | true, false => prim(AEAD_DEC k c (apply_rewrites l ad))
                      | false, true => prim(AEAD_DEC (apply_rewrites l k) (prim (AEAD_ENC (apply_rewrites l k') m ad)) ad)
                      | false, false => prim(AEAD_DEC (apply_rewrites l k) (prim (AEAD_ENC (apply_rewrites l k') m (apply_rewrites l ad))) (apply_rewrites l ad))
                    end
                  | _ => prim(AEAD_DEC (apply_rewrites l k) (apply_rewrites l c) (apply_rewrites l ad))
                end
              | _ => prim(AEAD_DEC (apply_rewrites l k) (apply_rewrites l c) (apply_rewrites l ad))
            end
          | PKE_ENC gk m => prim(PKE_ENC (apply_rewrites l gk) (apply_rewrites l m))
          | PKE_DEC k c => match c with
              | prim p' => match p' with
                  | PKE_ENC gk m => match gk with
                      | eq e => match e with
                          | PUBKEY _ exp => match value_beq exp k with
                              | true => m
                              | false => prim(PKE_DEC (apply_rewrites l k) (prim(PKE_ENC (apply_rewrites l exp) m)))
                            end
                          | _ => prim(PKE_DEC k (apply_rewrites l c))
                        end
                      | _ => prim(PKE_DEC (apply_rewrites l k) (apply_rewrites l c))
                    end
                | _ => prim(PKE_DEC (apply_rewrites l k) (apply_rewrites l c))
                    end
              | _ => prim(PKE_DEC (apply_rewrites l k) (apply_rewrites l c))
            end
          | HASH1 a => prim(HASH1 (apply_rewrites l a))
          | HASH2 a b => prim(HASH2 (apply_rewrites l a) (apply_rewrites l b))
          | HASH3 a b c => prim(HASH3 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c))
          | HASH4 a b c d => prim(HASH4 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d))
          | HASH5 a b c d e => prim(HASH5 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d) (apply_rewrites l e))
          | MAC k m => prim(MAC (apply_rewrites l k) (apply_rewrites l m))
          | HKDF1 salt ikm info => prim(HKDF1 (apply_rewrites l salt) (apply_rewrites l ikm) (apply_rewrites l info))
          | HKDF2 salt ikm info => prim(HKDF2 (apply_rewrites l salt) (apply_rewrites l ikm) (apply_rewrites l info))
          | HKDF3 salt ikm info => prim(HKDF3 (apply_rewrites l salt) (apply_rewrites l ikm) (apply_rewrites l info))
          | HKDF4 salt ikm info => prim(HKDF4 (apply_rewrites l salt) (apply_rewrites l ikm) (apply_rewrites l info))
          | HKDF5 salt ikm info => prim(HKDF5 (apply_rewrites l salt) (apply_rewrites l ikm) (apply_rewrites l info))
          | PW_HASH1 a => prim(PW_HASH1 (apply_rewrites l a))
          | PW_HASH2 a b => prim(PW_HASH2 (apply_rewrites l a) (apply_rewrites l b))
          | PW_HASH3 a b c => prim(PW_HASH3 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c))
          | PW_HASH4 a b c d => prim(PW_HASH4 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d))
          | PW_HASH5 a b c d e => prim(PW_HASH5 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d) (apply_rewrites l e))
          | SIGN k m => prim(SIGN (apply_rewrites l k) (apply_rewrites l m))
          | SIGNVERIF k m s => match s with
              | prim p' => match p' with
                  | SIGN k' m' => match value_beq k k', value_beq m m' with
                      | true, true => m
                      | true, false => prim(SIGNVERIF k (apply_rewrites l m) (prim(SIGN k (apply_rewrites l m'))))
                      | false, true => prim(SIGNVERIF (apply_rewrites l k) m (prim(SIGN (apply_rewrites l k') m')))
                      | false, false => prim(SIGNVERIF (apply_rewrites l k) (apply_rewrites l m) (prim(SIGN (apply_rewrites l k') (apply_rewrites l m'))))
                    end
                  | _ => prim(SIGNVERIF (apply_rewrites l k) (apply_rewrites l m) (apply_rewrites l s))
                end
              | _ => prim(SIGNVERIF (apply_rewrites l k) (apply_rewrites l m) (apply_rewrites l s))
            end
          | RINGSIGN ka gkb gkc m => prim(RINGSIGN (apply_rewrites l ka) (apply_rewrites l gkb) (apply_rewrites l gkc) (apply_rewrites l m))
          | RINGSIGNVERIF gka gkb gkc m s => match s with
              | prim p' => match p' with
                  | RINGSIGN ka' gkb' gkc' m' => match value_beq m m' with
                      | false => prim(RINGSIGNVERIF gka gkb gkc (apply_rewrites l m) (prim(RINGSIGN ka' gkb' gkc' (apply_rewrites l m))))
                      | true => match gka, gkb, gkc with
                          | eq e1, eq e2, eq e3 => match e1, e2, e3 with
                              | PUBKEY _ ka, PUBKEY _ kb, PUBKEY _ kc => match (value_beq ka' ka) && (((value_beq gkb' gkb) && (value_beq gkc' gkc)) || ((value_beq gkb' gkc) && (value_beq gkc' gkb))) with
                                  | true => m
                                  | false => match (value_beq ka' kb) && (((value_beq gkb' gkc) && (value_beq gkc' gka)) || ((value_beq gkb' gka) && (value_beq gkc' gkc))) with
                                      | true => m
                                      | false => match (value_beq ka' kc) && (((value_beq gkb' gkb) && (value_beq gkc' gka)) || ((value_beq gkb' gka) && (value_beq gkc' gkb))) with
                                          | true => m
                                          | false => prim(RINGSIGNVERIF (apply_rewrites l gka) (apply_rewrites l gkb) (apply_rewrites l gkc) m (prim(RINGSIGN (apply_rewrites l ka') (apply_rewrites l gkb') (apply_rewrites l gkc') m')))
                                        end
                                   end
                               end
                              | _, _, _ => prim(RINGSIGNVERIF (apply_rewrites l gka) (apply_rewrites l gkb) (apply_rewrites l gkc) m (prim(RINGSIGN ka' gkb' gkc' m')))
                          end
                        | _, _, _ => prim(RINGSIGNVERIF (apply_rewrites l gka) (apply_rewrites l gkb) (apply_rewrites l gkc) m (prim(RINGSIGN ka' gkb' gkc' m')))
                  end 
                  end
                  | _ => prim(RINGSIGNVERIF gka gkb gkc m (apply_rewrites l s))
                  end
              | _ => prim(RINGSIGNVERIF gka gkb gkc m (apply_rewrites l s))
            end
          | BLIND k m => prim(BLIND (apply_rewrites l k) (apply_rewrites l m))
          | UNBLIND k m s => match s with
              | prim p' => match p' with
                  | SIGN a b => match b with
                      | prim p'' => match p'' with
                          | BLIND k' m' => match value_beq k k', value_beq m m' with
                              | true, true => prim(SIGN a m)
                              | true, false => prim(UNBLIND k (apply_rewrites l m) (prim(SIGN a (prim(BLIND k' (apply_rewrites l m'))))))
                              | false, true => prim(UNBLIND (apply_rewrites l k) m (prim(SIGN a (prim(BLIND (apply_rewrites l k') m')))))
                              | false, false => prim(UNBLIND (apply_rewrites l k) (apply_rewrites l m) (prim(SIGN a (prim(BLIND (apply_rewrites l k') (apply_rewrites l m'))))))
                            end
                            | _ => prim(UNBLIND k m (prim(SIGN a (apply_rewrites l b))))
                            end
                  | _ => prim(UNBLIND k m (prim(SIGN a (apply_rewrites l b))))
                  end
                  | _ => prim(UNBLIND k m (apply_rewrites l s))
                end
              | _ => prim(UNBLIND k m (apply_rewrites l s))
            end
          | SHAMIR_SPLIT1 k => prim(SHAMIR_SPLIT1 (apply_rewrites l k))
          | SHAMIR_SPLIT2 k => prim(SHAMIR_SPLIT2 (apply_rewrites l k))
          | SHAMIR_SPLIT3 k => prim(SHAMIR_SPLIT3 (apply_rewrites l k))
          | SHAMIR_JOIN psa psb => match psa, psb with
              | prim sa, prim sb => match sa, sb with
                  | SHAMIR_SPLIT1 k, SHAMIR_SPLIT2 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | SHAMIR_SPLIT1 k, SHAMIR_SPLIT3 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | SHAMIR_SPLIT2 k, SHAMIR_SPLIT1 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | SHAMIR_SPLIT2 k, SHAMIR_SPLIT3 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | SHAMIR_SPLIT3 k, SHAMIR_SPLIT1 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | SHAMIR_SPLIT3 k, SHAMIR_SPLIT2 k' => match value_beq k k' with
                      | true => k
                      | false => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                    end
                  | _, _ => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
                end
                | _, _ => prim(SHAMIR_JOIN (apply_rewrites l psa) (apply_rewrites l psb))
              end
          | CONCAT2 a b => prim(CONCAT2 (apply_rewrites l a) (apply_rewrites l b))
          | CONCAT3 a b c => prim(CONCAT3 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c))
          | CONCAT4 a b c d => prim(CONCAT4 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d))
          | CONCAT5 a b c d e => prim(CONCAT5 (apply_rewrites l a) (apply_rewrites l b) (apply_rewrites l c) (apply_rewrites l d) (apply_rewrites l e))
          | SPLIT1 a => prim(SPLIT1 (apply_rewrites l a))
          | SPLIT2 a => prim(SPLIT2 (apply_rewrites l a))
          | SPLIT3 a => prim(SPLIT3 (apply_rewrites l a))
          | SPLIT4 a => prim(SPLIT4 (apply_rewrites l a))
          | SPLIT5 a => prim(SPLIT5 (apply_rewrites l a))
        end
 end.

Fixpoint rewrite_list (l: list value) (i n: nat): list value :=
  match n with
      | 0 => l
      | S n' => match ((List.length l) =? i) with
          | true => l
          | false => match l with
              | [] => []
              | h :: t =>
              let v := (nth i l default) in
              let v' := apply_rewrites l v in
              let diff := rewrite_diff v v' in
                  match value_beq v diff with
                  | true => rewrite_list l (i+1) n'
                  | false => rewrite_list ((remove_value_list l v) ++ [diff]) 0 n'
                end
            end
        end
    end.

Fixpoint rewrite_principals (l: list (list value)) (n: nat) : list(list value) :=
  match l with
    | [] => [[]]
    | h :: t => [(rewrite_list h 0 n)] ++ (rewrite_principals t n)
  end.


Fixpoint decompose_primitive (l: list value) (p: primitive) (n: nat) : list value :=
  match n with
    | 0 => l
    | S n' => match p with
          | ENC k m => let l' := (merge_lists l (find l k n')) in
            match shallow_search l' k with
              | true => l' ++ [m]
              | false => l'
            end
          | DEC k c => let l' := (merge_lists l (find l k n')) in
            match shallow_search l' k with
              | true => l' ++ [c]
              | false => l'
            end
          | AEAD_ENC k m ad => let l' := (merge_lists l (find l k n')) in
            match shallow_search l' k with
              | true => l' ++ [m]
              | false => l'
            end
          | AEAD_DEC k c ad => let l' := (merge_lists l (find l k n')) in
            match shallow_search l' k with
              | true => l' ++ [c]
              | false => l'
            end
          | PKE_ENC gk m => match gk with
              | eq e => match e with
                  | PUBKEY _ exp => let l' := (merge_lists l (find l exp n')) in
                    match shallow_search l' exp with
                        | true => l' ++ [m]
                        | false => l'
                      end
                  | _ => l
                end
              | _ => l
            end
          | PKE_DEC k c => let l' := (merge_lists l (find l k n')) in
            match shallow_search l' k with
              | true => l' ++ [c]
              | false => l'
            end
            | BLIND k m => let l' := (merge_lists l (find l k n')) in
              match shallow_search l' k with
                | true => l' ++ [m]
                | false => l'
              end
            | _ => l
          end
    end
with reconstruct_primitive (l: list value) (p: primitive) (n: nat) : list value :=
  match n with
    | 0 => l
    | S n' => match p with
        | ENC k m => let l' := find l k n' in
          let l'' := find l' m n' in
            match shallow_search l'' k, shallow_search l'' m with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | DEC k c => let l' := find l k n' in
          let l'' := find l' c n' in
            match shallow_search l'' k, shallow_search l'' c with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | AEAD_ENC k m ad => let l' := find l k n' in
          let l'' := find l' m n' in
          let l''' := find l'' ad n' in
          match shallow_search l''' k, shallow_search l''' m, shallow_search l''' ad with
            | true, true, true => l''' ++ [prim p]
            | _, _, _ => l'''
          end
        | AEAD_DEC k c ad => let l' := find l k n' in
          let l'' := find l' c n' in
          let l''' := find l'' ad n' in
          match shallow_search l''' k, shallow_search l''' c, shallow_search l''' ad with
            | true, true, true => l''' ++ [prim p]
            | _, _, _ => l'''
          end
        | PKE_ENC gk m => let l' := find l gk n' in
          let l'' := find l' m n' in
          match shallow_search l'' gk, shallow_search l'' m with
            | true, true => l'' ++ [prim p]
            | _, _ => l''
          end
        | PKE_DEC k c => let l' := find l k n' in
          let l'' := find l' c n' in
          match shallow_search l'' k, shallow_search l'' c with
            | true, true => l'' ++ [prim p]
            | _, _ => l''
          end
        | HASH1 a => let l' := find l a n' in
          match shallow_search l' a with
            | true => l' ++ [prim p]
            | false => l'
          end
        | HASH2 a b => let l' := find l a n' in
          let l'' := find l' b n' in
          match shallow_search l'' a, shallow_search l'' b with
            | true, true => l'' ++ [prim p]
            | _, _ => l''
          end
        | HASH3 a b c => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          match shallow_search l''' a, shallow_search l''' b, shallow_search l''' c with
            | true, true, true => l''' ++ [prim p]
            | _, _, _ => l'''
          end
        | HASH4 a b c d => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          let l'''' := find l''' d n' in
          match shallow_search l'''' a, shallow_search l'''' b, shallow_search l'''' c, shallow_search l'''' d with
            | true, true, true, true => l'''' ++ [prim p]
            | _, _, _, _ => l''''
          end
        | HASH5 a b c d e => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          let l'''' := find l''' d n' in
          let l''''' := find l'''' e n' in
          match shallow_search l''''' a, shallow_search l''''' b, shallow_search l''''' c, shallow_search l''''' d, shallow_search l''''' e with
            | true, true, true, true, true => l''''' ++ [prim p]
            | _, _, _, _, _ => l'''''
          end
        | MAC k m => let l' := find l k n' in
          let l'' := find l' m n' in
            match shallow_search l'' k, shallow_search l'' m with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | HKDF1 salt ikm info => let l' := find l salt n' in
          let l'' := find l' ikm n' in
          let l''' := find l'' info n' in
          match shallow_search l''' salt, shallow_search l''' ikm, shallow_search l''' info with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | HKDF2 salt ikm info => let l' := find l salt n' in
          let l'' := find l' ikm n' in
          let l''' := find l'' info n' in
          match shallow_search l''' salt, shallow_search l''' ikm, shallow_search l''' info with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | HKDF3 salt ikm info => let l' := find l salt n' in
          let l'' := find l' ikm n' in
          let l''' := find l'' info n' in
          match shallow_search l''' salt, shallow_search l''' ikm, shallow_search l''' info with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | HKDF4 salt ikm info => let l' := find l salt n' in
          let l'' := find l' ikm n' in
          let l''' := find l'' info n' in
          match shallow_search l''' salt, shallow_search l''' ikm, shallow_search l''' info with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | HKDF5 salt ikm info => let l' := find l salt n' in
          let l'' := find l' ikm n' in
          let l''' := find l'' info n' in
          match shallow_search l''' salt, shallow_search l''' ikm, shallow_search l''' info with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | PW_HASH1 a => let l' := find l a n' in
          match shallow_search l' a with
            | true => l' ++ [prim p]
            | false => l'
          end
        | PW_HASH2 a b => let l' := find l a n' in
          let l'' := find l' b n' in
          match shallow_search l'' a, shallow_search l'' b with
            | true, true => l'' ++ [prim p]
            | _, _ => l''
          end
        | PW_HASH3 a b c => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          match shallow_search l''' a, shallow_search l''' b, shallow_search l''' c with
            | true, true, true => l''' ++ [prim p]
            | _, _, _ => l'''
          end
        | PW_HASH4 a b c d => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          let l'''' := find l''' d n' in
          match shallow_search l'''' a, shallow_search l'''' b, shallow_search l'''' c, shallow_search l'''' d with
            | true, true, true, true => l'''' ++ [prim p]
            | _, _, _, _ => l''''
          end
        | PW_HASH5 a b c d e => let l' := find l a n' in
          let l'' := find l' b n' in
          let l''' := find l'' c n' in
          let l'''' := find l''' d n' in
          let l''''' := find l'''' e n' in
          match shallow_search l''''' a, shallow_search l''''' b, shallow_search l''''' c, shallow_search l''''' d, shallow_search l''''' e with
            | true, true, true, true, true => l''''' ++ [prim p]
            | _, _, _, _, _ => l'''''
          end
        | SIGN k m => let l' := find l k n' in
          let l'' := find l' m n' in
            match shallow_search l'' k, shallow_search l'' m with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end

        | SIGNVERIF k m s => let l' := find l k n' in
            let l'' := find l' m n' in
            let l''' := find l'' s n' in
            match shallow_search l''' k, shallow_search l''' m, shallow_search l''' s with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | RINGSIGN ka gkb gkc m => let l' := find l ka n' in
            let l'' := find l' gkb n' in
            let l''' := find l'' gkc n' in
            let l'''' := find l''' m n' in
            match shallow_search l'''' ka, shallow_search l'''' gkb, shallow_search l'''' gkc, shallow_search l'''' m with
              | true, true, true, true => l'''' ++ [prim p]
              | _, _, _, _ => l''''
            end
          | RINGSIGNVERIF gka gkb gkc m s => let l' := find l gka n' in
            let l'' := find l' gkb n' in
            let l''' := find l'' gkc n' in
            let l'''' := find l''' m n' in
            let l''''' := find l'''' s n' in
            match shallow_search l''''' gka, shallow_search l''''' gkb, shallow_search l''''' gkc, shallow_search l''''' m, shallow_search l''''' s with
              | true, true, true, true, true => l''''' ++ [prim p]
              | _, _, _, _, _ => l'''''
            end
        | BLIND k m => let l' := find l k n' in
          let l'' := find l' m n' in
            match shallow_search l'' k, shallow_search l'' m with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | UNBLIND k m b => let l' := find l k n' in
            let l'' := find l' m n' in
            let l''' := find l'' b n' in
            match shallow_search l''' k, shallow_search l''' m, shallow_search l''' b with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | SHAMIR_SPLIT1 k => let l' := find l k n' in
            match shallow_search l' k with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SHAMIR_SPLIT2 k => let l' := find l k n' in
            match shallow_search l' k with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SHAMIR_SPLIT3 k => let l' := find l k n' in
            match shallow_search l' k with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SHAMIR_JOIN sa sb => let l' := find l sa n' in
            let l'' := find l' sb n' in
            match shallow_search l'' sa, shallow_search l'' sb with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | CONCAT2 a b => let l' := find l a n' in
            let l'' := find l' b n' in
            match shallow_search l'' a, shallow_search l'' b with
              | true, true => l'' ++ [prim p]
              | _, _ => l''
            end
        | CONCAT3 a b c => let l' := find l a n' in
            let l'' := find l' b n' in
            let l''' := find l'' c n' in
            match shallow_search l''' a, shallow_search l''' b, shallow_search l''' c with
              | true, true, true => l''' ++ [prim p]
              | _, _, _ => l'''
            end
        | CONCAT4 a b c d => let l' := find l a n' in
            let l'' := find l' b n' in
            let l''' := find l'' c n' in
            let l'''' := find l''' d n' in
            match shallow_search l'''' a, shallow_search l'''' b, shallow_search l'''' c, shallow_search l'''' d with
              | true, true, true, true => l'''' ++ [prim p]
              | _, _, _, _ => l''''
            end
        | CONCAT5 a b c d e  => let l' := find l a n' in
            let l'' := find l' b n' in
            let l''' := find l'' c n' in
            let l'''' := find l''' d n' in
            let l''''' := find l'''' e n' in
            match shallow_search l''''' a, shallow_search l''''' b, shallow_search l''''' c, shallow_search l''''' d, shallow_search l''''' e with
              | true, true, true, true, true => l''''' ++ [prim p]
              | _, _, _, _, _ => l'''''
            end
        | SPLIT1 a => let l' := find l a n' in
            match shallow_search l' a with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SPLIT2 a => let l' := find l a n' in
            match shallow_search l' a with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SPLIT3 a => let l' := find l a n' in
            match shallow_search l' a with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SPLIT4 a => let l' := find l a n' in
            match shallow_search l' a with
              | true => l' ++ [prim p]
              | false => l'
            end
        | SPLIT5 a => let l' := find l a n' in
            match shallow_search l' a with
              | true => l' ++ [prim p]
              | false => l'
            end
      end
 end
with reconstruct_equation (l: list value) (e: equation) (n: nat) : list value :=
  match n with
    | 0 => l
    | S n' => match e with
        | PUBKEY _ exp => let l' := find l exp n' in
            match shallow_search l' exp with
              | true => l' ++ [eq e]
              | false => l'
            end
        | DH _ exp1 exp2 => let l' := find l exp1 n' in
            match shallow_search l' exp1 with
              | true => let l'' := find l' exp2 n' in
                  match shallow_search l'' exp2 with
                    | true => l'' ++ [eq e]
                    | false => let gexp2 := (eq (PUBKEY G exp2)) in
                      let l''' := find l'' gexp2 n' in
                      match shallow_search l''' gexp2 with
                        | true => l''' ++ [eq e]
                        | false => l'''
                      end
                 end
              | false => let gexp1 := (eq (PUBKEY G exp1)) in
                let l'' := find l' gexp1 n' in
                match shallow_search l'' gexp1 with
                  | true => let l''' := find l'' exp2 n' in
                    match shallow_search l''' exp2 with
                      | true => l''' ++ [eq e]
                      | false => l'''
                   end
                  | false => l''
                end
            end
      end
  end
with find (l: list value) (goal: value) (n: nat) : list value := 
    match n with
      | 0 => l
      | S n' => match shallow_search l goal with
          | true => l
          | false => match goal with
              | const c => l
              | pass a => l
              | default => l
              | eq e => reconstruct_equation l e n'
              | prim p => let l' := decompose_primitive l p n' in
                  match shallow_search l' goal with
                    | true => l'
                    | false => reconstruct_primitive l' p n'
                  end 
            end
        end
    end.

Fixpoint analysis_decompose (l: list value) (i n: nat): list value :=
match n with
| 0 => l
| S n' => match ((List.length l) =? i) with
    | true => l
    | false => match l with
        | [] => []
        | h :: t =>
        let v := (nth i l default) in
        match v with
          | prim p => let l' := decompose_primitive l p n' in
              match (List.length l =? List.length l') with
                | true => analysis_decompose l (i+1) n'
                | false => analysis_decompose l' 0 n'
                end
          | _ => analysis_decompose l (i+1) n'
          end
      end
  end
end.

Fixpoint analysis_concat (l: list value) : list value :=
  match l with
    | [] => []
    | h :: t => match h with
        | prim p => match p with
            | CONCAT2 a b =>  [a; b] ++ analysis_concat t
            | CONCAT3 a b c => [a; b; c] ++ analysis_concat t
            | CONCAT4 a b c d => [a; b; c; d] ++ analysis_concat t
            | CONCAT5 a b c d e => [a; b; c; d; e] ++ analysis_concat t
            | _ => [h] ++ analysis_concat t
            end
        | _ => [h] ++ analysis_concat t
      end
  end.


Inductive query : Type :=
  | confidentiality: value -> query.

Definition resolve_query (q: query) (l: list value) : bool := 
  match q with
    | confidentiality v => shallow_search l v
  end.

Fixpoint recompose (l: list value) (v: value) : list value :=
  match ((shallow_search l (prim(SHAMIR_SPLIT1 v)) && shallow_search l (prim(SHAMIR_SPLIT2 v)))
    || (shallow_search l (prim(SHAMIR_SPLIT1 v)) && shallow_search l (prim(SHAMIR_SPLIT3 v)))
    || (shallow_search l (prim(SHAMIR_SPLIT2 v)) && shallow_search l (prim(SHAMIR_SPLIT3 v))) 
    )  with
    | true => l ++ [v]
    | false => l
  end.

Fixpoint recompose_analysis (l: list value) (pl: list (list value)) (n: nat) : list value :=
match n with
  | 0 => l
  | S n' => match pl with
    | [] => l
    | h :: t => match h with
        | [] => merge_lists l (recompose_analysis l t n')
        | h' :: t' => let l' := recompose l h' in
            merge_lists l' (recompose_analysis l' ([t']++ t) n')
          end
          end
        end.

Fixpoint reconstruct_analysis (l: list value) (pl: list(list value)) (n: nat) : list value :=
  match n with
    | 0 => l
    | S n' => match pl with
        | [] => l
        |  h :: t => match h with
            | [] => merge_lists l (reconstruct_analysis l t n')
            | h' :: t' => match h' with
                | prim p => let l' := reconstruct_primitive l p n' in
                   merge_lists l' (reconstruct_analysis l' ([t'] ++ t) n')
                | eq e => let l' := reconstruct_equation l e n' in
                  merge_lists l' (reconstruct_analysis l' ([t'] ++ t) n')
                | _ => merge_lists l (reconstruct_analysis l ([t'] ++ t) n')
              end
          end
      end
  end.
             

Fixpoint analysis (q: query) (ak: list value) (p: list (list value)) (n: nat) : bool :=
  match n with
    | 0 => true
    | S n' => match ak with
        | [] => true
        | _ => let ak2 := analysis_decompose ak 0 n' in
            let ak3 := analysis_concat ak2 in
            let ak4 := recompose_analysis ak3 p n' in
            let ak5 := reconstruct_analysis ak4 p n'
          in match resolve_query q ak with
              | true => false
              | false => match (List.length ak =? List.length ak5) with
                  | true => true
                  | false => analysis q ak5 p n'
                end
           end
       end
  end.