// Copyright 2019-2020 CERN and copyright holders of ALICE O2.
// See https://alice-o2.web.cern.ch/copyright for details of the copyright holders.
// All rights not expressly granted are reserved.
//
// This software is distributed under the terms of the GNU General Public
// License v3 (GPL Version 3), copied verbatim in the file "COPYING".
//
// In applying this license CERN does not waive the privileges and immunities
// granted to it by virtue of its status as an Intergovernmental Organization
// or submit itself to any jurisdiction.

// O2:
#include <CCDB/BasicCCDBManager.h>
#include "Framework/runDataProcessing.h"
#include "Framework/AnalysisTask.h"
#include "Framework/AnalysisDataModel.h"
#include "Framework/DataTypes.h"
#include "Common/DataModel/TrackSelectionTables.h" // needed for aod::TracksDCA table
#include "Common/DataModel/EventSelection.h"
#include "Common/DataModel/Multiplicity.h"
#include "Common/DataModel/Centrality.h"
// ...

using namespace o2;
using namespace o2::framework; 
// ...

// Definitions of join tables for Run 3 analysis:
using EventSelection = soa::Join<aod::EvSels, aod::Mults, aod::CentFT0Ms, aod::CentFV0As, aod::CentNTPVs>;
using CollisionRec = soa::Join<aod::Collisions, EventSelection>::iterator; // use in json "isMC": "true" for "event-selection-task"
using CollisionRecSim = soa::Join<aod::Collisions, aod::McCollisionLabels, EventSelection>::iterator;
using CollisionSim = aod::McCollision;
using TracksRec = soa::Join<aod::Tracks, aod::TracksExtra, aod::TracksDCA, aod::TrackSelection>;
using TrackRec = soa::Join<aod::Tracks, aod::TracksExtra, aod::TracksDCA, aod::TrackSelection>::iterator;
using TracksRecSim = soa::Join<aod::Tracks, aod::TracksExtra, aod::TracksDCA, aod::TrackSelection, aod::McTrackLabels>; // + use in json "isMC" : "true"
using TrackRecSim = soa::Join<aod::Tracks, aod::TracksExtra, aod::TracksDCA, aod::TrackSelection, aod::McTrackLabels>::iterator;
using TracksSim = aod::McParticles;
using TrackSim = aod::McParticles::iterator;
// ...

// *) ROOT and C++ include's:
#include <TH1D.h>
// ...

using namespace std;
// ...

// *) Define enums:
enum eRecSim { eRec = 0,
               eSim,
               eRecAndSim };

enum eProcess {
  eProcessRec = 0,     // Run 3, only reconstructed
  eProcessRecSim,      // Run 3, both reconstructed and simulated
  eProcessSim,         // Run 3, only simulated
  eProcess_N
};


// *) Main task:
struct StudentO2Physics { // this name is used in lower-case format to name the TDirectoryFile in AnalysisResults.root


  // *) Base TList to hold all output objects:
  TString sBaseListName = "Default list name"; // yes, I declare it separately, because I need it also later in BailOut() function
  OutputObj<TList> fBaseList{sBaseListName.Data(),
                             OutputObjHandlingPolicy::AnalysisObject,
                             OutputObjSourceType::OutputObjSource};


  // *) CCDB:
  // Service<ccdb::BasicCCDBManager> ccdb; // support for offline callibration data base, not needed for the time being...


  // *) Define configurables:
  Configurable<bool> cfDryRun{"cfDryRun", false, "book all histos and run without filling and calculating anything"}; // example for built-in type (float, string, etc.)
  Configurable<vector<float>> cf_pt_bins{"cf_pt_bins", {1000, 0., 100.}, "nPtBins, ptMin, ptMax"}; // example for an array


  // *) Define and initialize all data members to be called in the main process* functions:
  // **) Task configuration:
struct TaskConfiguration {
  Bool_t fProcess[eProcess_N] = {kFALSE}; // Set what to process. See enum eProcess for full description. Set via implicit variables within a PROCESS_SWITCH clause.
  Bool_t fDryRun = kFALSE;       // book all histos and run without filling and calculating anything
} tc; // you have to prepend "tc." for all objects name in this group later in the code
 
  // **) Particle histograms:
struct ParticleHistograms {
  TList* fParticleHistogramsList = NULL;  //!<! list to hold all control particle histograms
  TH1F* fHistPt[2] = {NULL};              // pt distribution of a particle [ 0 = rec, 1 = sim ]
} pc; // you have to prepend "pc." for all objects name in this group later in the code
 
  // ... 


  // *) Define all member functions to be called in the main process* functions:
  template <eRecSim rs, typename T1, typename T2> void Steer(T1 const& collision, T2 const& tracks) {

    // Dry run:
    if (tc.fDryRun) {
      return;
    }

    // Print current run number:
    LOGF(info, "Run number: %d", collision.bc().runNumber());

    // Print centrality estimated with "FT0M" estimator:
    LOGF(info, "Centrality: %f", collision.centFT0M());
  
    // Print vertex X position:
    LOGF(info, "Vertex X position: %f", collision.posX());

    // Main loop over particles:
    auto track = tracks.iteratorAt(0); // set the type and scope from one instance
    for (int64_t i = 0; i < tracks.size(); i++) {
    
      // Print track azimuthal angle:
      // LOGF(info, "Track azimuthal angle: %f", track.phi());

      // Fill reconstructed ...:
      if constexpr (rs == eRec || rs == eRecAndSim) {
        // Fill track pt distribution:
        pc.fHistPt[eRec]->Fill(track.pt());      
        // ... 

        // ... and corresponding MC truth simulated:
        // See https://github.com/AliceO2Group/O2Physics/blob/master/Tutorials/src/mcHistograms.cxx
        // See https://aliceo2group.github.io/analysis-framework/docs/datamodel/ao2dTables.html#montecarlo
        if constexpr (rs == eRecAndSim) {
          if (!track.has_mcParticle()) {
          LOGF(warning, "  No MC particle for this track, skip...");
          return;
        }
        auto mcparticle = track.mcParticle(); // corresponding MC truth simulated particle
        pc.fHistPt[eSim]->Fill(mcparticle.pt());
       } // end of if constexpr (rs == eRecAndSim) {

      } // if constexpr (rs == eRec || rs == eRecAndSim) {

    } // end of for (int64_t i = 0; i < tracks.size(); i++) { 
    
  } // end of template <eRecSim rs, typename T1, typename T2> void Steer(T1 const& collision, T2 const& tracks) {
  
   
  // *) Initialize and book all objects:
  void init(InitContext&) {
   
   // ... code to book and initialize all analysis objects ...  
 
   // *) Set automatically what to process, from an implicit variable "doprocessSomeProcessName" within a PROCESS_SWITCH clause:
   tc.fProcess[eProcessRec] = doprocessRec;
   tc.fProcess[eProcessRecSim] = doprocessRecSim;
   tc.fProcess[eProcessSim] = doprocessSim;


   // *) Configure your task using configurables in the json file:
   tc.fDryRun = cfDryRun;


   // *) Book base list:
   TList* temp = new TList();
   temp->SetOwner(kTRUE);
   fBaseList.setObject(temp);

 
   // *) Book and nest all other TLists:
   pc.fParticleHistogramsList = new TList();
   pc.fParticleHistogramsList->SetName("ParticleHistograms");
   pc.fParticleHistogramsList->SetOwner(kTRUE);
   fBaseList->Add(pc.fParticleHistogramsList); // any nested TList in the base TList appears as a subdir in the output ROOT file

  
   // *) Book pt distribution with binning defined through configurables in the json file:
   vector<float> l_pt_bins = cf_pt_bins.value; // define local array and initialize it from an array set in the configurables
   Int_t nBins = (Int_t) l_pt_bins[0];
   Float_t min = l_pt_bins[1];
   Float_t max = l_pt_bins[2];
   pc.fHistPt[eRec] = new TH1F("fHistPt[eRec]", "pt distribution for reconstructed particles", nBins, min, max);
   pc.fHistPt[eRec]->GetXaxis()->SetTitle("p_{T}");
   pc.fParticleHistogramsList->Add(pc.fHistPt[eRec]);   

   pc.fHistPt[eSim] = new TH1F("fHistPt[eSim]", "pt distribution for simulated particles", nBins, min, max);
   pc.fHistPt[eSim]->GetXaxis()->SetTitle("p_{T}");
   pc.fParticleHistogramsList->Add(pc.fHistPt[eSim]);   

  } // end of void init(InitContext&) {


  // A) Process only reconstructed data:
  void processRec(CollisionRec const& collision, aod::BCs const&, TracksRec const& tracks)
  {
    // ...
    
    // *) Steer all analysis steps:
    Steer<eRec>(collision, tracks);

  }
  PROCESS_SWITCH(StudentO2Physics, processRec, "process only reconstructed data", true); // yes, keep always one process switch "true", so that there is default running version

  // -------------------------------------------

  // B) Process both reconstructed and corresponding MC truth simulated data:
  void processRecSim(CollisionRecSim const& collision, aod::BCs const&, TracksRecSim const& tracks, aod::McParticles const&, aod::McCollisions const&)
  {
    Steer<eRecAndSim>(collision, tracks);
  }
  PROCESS_SWITCH(StudentO2Physics, processRecSim, "process both reconstructed and corresponding MC truth simulated data", false);

  // -------------------------------------------

  // C) Process only simulated data:
  void processSim(CollisionSim const& /*collision*/, aod::BCs const&, TracksSim const& /*tracks*/)
  {
    // Steer<eSim>(collision, tracks); // TBI 20241105 not ready yet, but I do not really need this one urgently, since RecSim is working, and I need that one for efficiencies...
  }
  PROCESS_SWITCH(StudentO2Physics, processSim, "process only simulated data", false);

}; // struct StudentO2Physics {

// *) The final touch: 
WorkflowSpec defineDataProcessing(ConfigContext const& cfgc)
{
  return WorkflowSpec{
    adaptAnalysisTask<StudentO2Physics>(cfgc),
  };
} // WorkflowSpec...
