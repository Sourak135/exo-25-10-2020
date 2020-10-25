// SPDX-License-Identifier: MIT              
pragma solidity ^0.6.0; 
pragma experimental ABIEncoderV2;

contract Votez {

    struct Proposal{
        uint id; // id de la proposition
        bool active; // proposition toujours active pour être votée - pas utilisée pour le moment
        string question; // la proposition
        string description; // une description de la proposition
        uint forVotes; // nombre de vote `Yes`
        uint againstVotes; // nombre de vote `No`
        uint blankVotes; // nombre de vote `Blank`
        uint delay; // date à laquelle la proposition ne sera plus valide
        mapping (address => bool) didVote; // mapping pour verifier si déjà voté
    }
    struct Membres{
        uint256 membershiptime; //temps d'abonnement - pas encore implémenté
        uint256 warnings; // avertissements
    //  bool membre; //pertinent ou inutile?
        bool admin; // admin ou pas
    }
    
    
    //pour incrémenter les propositions
    uint256 private compteur;
    string public consignes_de_vote = "0 pour oui, 1 pour non, 2 pour blanc";
    address payable owner;
    
    mapping (uint => Proposal) private proposition;
    mapping (address => Membres ) public administration;
    
    constructor () public{
        owner = msg.sender;
        administration[owner].admin=true;
        administration[owner].membershiptime = 5200 weeks;
    }
    
    //choix de vote
    enum Referendum{ OUI, NON, BLANC }
    Referendum vote;
   
    //modifiers pour gérer l'administration
   modifier ownerOnly() {
       require (msg.sender==owner, 'Only owner can perform this action');
       _;
   }
   
    modifier adminOnly() {
        require(administration[msg.sender].admin, 'Only admins can perform this action');
       _;
  }
   
   // fonctions pour gérer les admins
   function passerAdmin(address _addr) public adminOnly {
       administration[_addr].admin = true;
   }
   
    function retirerAdmin(address _addr) public adminOnly {
       require(_addr != owner, "not allowed, owner stay admin");
       administration[_addr].admin = false;
   }
   
   //fonctions pour gérer les warnings
   function warningPlus(address _addr) public adminOnly {
       require(_addr != owner, "not allowed");
       administration[_addr].warnings +=1;
   }
   
   function warningMinus(address _addr) public adminOnly {
       require(_addr != owner, "not allowed");
       administration[_addr].warnings =0;
   }
   
   //fonction pour proposer un vote
   //sans doute a refaire en une ligne avec parenthèses - a réfléchir 
    function soumettreAuVote(string memory _question, string memory _description ) public {
        require (administration[msg.sender].warnings<2, "you are blacklisted");
        // système abbonnement pas encore op
        compteur+=1;
        proposition[compteur].id=compteur;
        proposition[compteur].active = true;
        proposition[compteur].question= _question;
        proposition[compteur].description = _description;
        proposition[compteur].delay = block.timestamp;
   }
   
   // 5 minutes pour voter a partir de la proposition
   function Vote(uint256 _id, Referendum _vote) public {
       
       require (proposition[_id].didVote[msg.sender]==false, "vous avez deja vote pour cette proposition");
       require ((proposition[_id].delay + 5 minutes )>(block.timestamp), "delai depasse, ce vote est fini");
       require (administration[msg.sender].warnings<2, "you are blacklisted");
       //système abonnement pas encore op
       if (_vote==Referendum.OUI){
           proposition[_id].forVotes +=1;
           proposition[_id].didVote[msg.sender]=true;
       }
       else if (_vote==Referendum.NON){
           proposition[_id].againstVotes +=1;
           proposition[_id].didVote[msg.sender]=true;
       }
       
       else if (_vote==Referendum.BLANC){
           proposition[_id].blankVotes +=1;
           proposition[_id].didVote[msg.sender]=true;
       }
       else {revert("choix invalide, seuls les choix OUI NON et BLANC sont comptés");}
   }
   
   // obtenir les résultats - il faut attendre fin du vote (5mins)
    function resultats (uint _id) public view returns (string memory, uint, uint, uint){
        require ((proposition[_id].delay + 5 minutes )<(block.timestamp), "le vote n est pas termine");
        
        if ((proposition[_id].forVotes > proposition[_id].againstVotes) && (proposition[_id].forVotes > proposition[_id].blankVotes)){
            return ("le Oui l'emporte",proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes) ;
        }
        else if ((proposition[_id].forVotes < proposition[_id].againstVotes) && (proposition[_id].againstVotes > proposition[_id].blankVotes)){
            return ("le Non l'emporte", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
        }
        else if ((proposition[_id].forVotes < proposition[_id].blankVotes) && (proposition[_id].forVotes < proposition[_id].blankVotes)){
            return ("le Blanc l'emporte", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
        }
        else {return ("le vote n'est pas décisif", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
            
        }
    } 

}