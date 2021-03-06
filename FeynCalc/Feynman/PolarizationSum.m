(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: PolarizationSum                                                   *)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2018 Rolf Mertig
	Copyright (C) 1997-2018 Frederik Orellana
	Copyright (C) 2014-2018 Vladyslav Shtabovenko
*)

(* :Summary:  Polarization sums for massive and massless vector
		bosons, e.g. photons, W's, Z's and gluons. The formulas
		used here can be found e.g. in M. Boehm, A. Denner and H. Joos,
		Gauge Theories of the Strong and Electroweak Interaction,
		Eq. A.1.45 and Eq. A.1.46.	*)

(* ------------------------------------------------------------------------ *)


PolarizationSum::usage =
"PolarizationSum[ mu,nu, ... ] defines (as abbreviations) different polarization sums. \
PolarizationSum[mu, nu] = -g(mu nu); \
PolarizationSum[mu, nu, k] = -g(mu nu) + k(mu) k(nu)/k^2; \
PolarizationSum[mu, nu, k, n] = polarization sum for spin 1 fields; \
(n = external momentum). \
PolarizationSum[mu, nu, k, 0] is equivalent to -g(mu nu)";

PolarizationSum::notmassless=
"Warning! You are inserting a polarization sum for massless vector bosons, \
but the momentum of the external boson `1` is not on-shell. Please put it on-shell \
via ScalarProduct[`1`,`1`]=0"

PolarizationSum::notmassive=
"Warning! You are inserting a polarization sum for massive vector bosons, \
but the momentum of the external boson `1` corresponds to a massless particle. \
Please define the proper mass via ScalarProduct[`1`,`1`]=mass^2. Otherwise, the result \
is not well defined."

PolarizationSum::auxerror=
"Warning! You are inserting a polarization sum for massive vector bosons, using \
the auxiliary vector `1`. However, the scalar product between the momentum of the \
external boson `2` and `1` is zero, which shouldn't be the case."

PolarizationSum::failmsg =
"Error! PolarizationSum has encountered a fatal problem and must abort the computation. \
The problem reads: `1`"

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`PolarizationSum`Private`"]

Options[PolarizationSum] = {
	Dimension -> 4,
	VirtualBoson -> False,
	Heads -> {LorentzIndex, LorentzIndex}
};

indSelect[type_, name_, dim_]:=
	Switch[type,
		LorentzIndex,
		LorentzIndex[name,dim],
		CartesianIndex,
		CartesianIndex[name,dim-1],
		TemporalIndex,
		TemporalIndex[],
		_,
		Message[PolarizationSum::failmsg,"Unknown head."];
		Abort[]
	];


(*    Polarization sum for massless vector bosons with gauge terms omitted,
	e.g. for photons in QED.     *)
PolarizationSum[mu_,nu_, OptionsPattern[]] :=
	-Pair[indSelect[OptionValue[Heads][[1]], mu , OptionValue[Dimension]],
		indSelect[OptionValue[Heads][[2]], nu , OptionValue[Dimension]]];

(*	Same as above. Putting the auxiliary vector n^mu to zero essentially
	omits the gauge terms.  *)
PolarizationSum[mu_,nu_, k_, 0, OptionsPattern[]] :=
	(If[ScalarProduct[k,k]=!=0 && !OptionValue[VirtualBoson],
			Message[PolarizationSum::notmassless, k]
	];
	-Pair[indSelect[OptionValue[Heads][[1]], mu , OptionValue[Dimension]],
		indSelect[OptionValue[Heads][[1]], nu , OptionValue[Dimension]]])/; k=!=0;

(*     Polarization sum for massive vector bosons, e.g. W's and Z's in the
	Electroweak Theory. Note that the particle mass enters as k^2, where k
	is the four-momentum of the boson.    *)
PolarizationSum[mu_,nu_, k_, OptionsPattern[]] :=
	Block[ {dim = OptionValue[Dimension],ind1, ind2},
		If[ScalarProduct[k,k]===0  && !OptionValue[VirtualBoson],
			Message[PolarizationSum::notmassive, k]
		];
		ind1 = indSelect[OptionValue[Heads][[1]], mu , dim];
		ind2 = indSelect[OptionValue[Heads][[2]], nu , dim];

		-Pair[ind1,ind2] +
		(Pair[Momentum[k,dim],ind1] Pair[Momentum[k,dim],ind2])/
		Factor2[ExpandScalarProduct[Momentum[k,dim],Momentum[k,dim]]]
	]/; k=!=0;

(*    Polarization sum for massless vector bosons with gauge terms included,
	e.g. for gluons in QCD. The auxiliary four-vector n^mu must satisfy
	n^mu eps_mu = 0 and n^mu k_mu != 0. Note that FeynCalc doesn't enforce
	these two conditions by itself, i.e. the user must ensure that they are
	satisfied.    *)
PolarizationSum[mu_,nu_, k_, n_, OptionsPattern[]] :=
	Block[ {dim = OptionValue[Dimension],ind1,ind2},
		If[ScalarProduct[k,k]=!=0 && !OptionValue[VirtualBoson],
			Message[PolarizationSum::notmassless, k]
		];
		If[ScalarProduct[n,k]===0,
			Message[PolarizationSum::auxerror,n, k]
		];
		ind1 = indSelect[OptionValue[Heads][[1]], mu , dim];
		ind2 = indSelect[OptionValue[Heads][[2]], nu , dim];


		(-Pair[ind1,ind2] -
		(Pair[Momentum[k,dim],ind1] Pair[Momentum[k,dim],ind2] *
		Factor2[ExpandScalarProduct[Momentum[n,dim],Momentum[n,dim]]])/
		Factor2[ExpandScalarProduct[Momentum[k,dim],Momentum[n,dim]]^2] +
		(Pair[Momentum[n,dim],ind1] Pair[Momentum[k,dim],ind2] +
		Pair[Momentum[k,dim],ind1] Pair[Momentum[n,dim],ind2])/
		Factor2[ExpandScalarProduct[Momentum[k,dim],Momentum[n,dim]]])//Collect2[#,Pair]&
	]/; k=!=0 && n=!=0;

FCPrint[1,"PolarizationSum.m loaded."];
End[]
