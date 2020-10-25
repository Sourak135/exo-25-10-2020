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
    
    //pour incrémenter les propositions
    uint256 private compteur;
    
    string public consignes_de_vote = "0 pour oui, 1 pour non, 2 pour blanc";
    
    
    mapping (uint => Proposal) private proposition;
    
    //choix de vote
    enum Referendum{ OUI, NON, BLANC }
    Referendum vote;
   
   
   //sans doute a refaire en une ligne avec parenthèses - a réfléchir 
    function soumettreAuVote(string memory _question, string memory _description ) public {
        compteur+=1;
        proposition[compteur].id=compteur;
        proposition[compteur].active = true;
        proposition[compteur].question= _question;
        proposition[compteur].description = _description;
        proposition[compteur].delay = block.timestamp;
   }
   
   //delai de 5 minutes pour vérifier fonctionnement ok
   function Vote(uint256 _id, Referendum _vote) public {
       
       require (proposition[_id].didVote[msg.sender]==false, "vous avez deja vote pour cette proposition");
       require ((proposition[_id].delay + 5 minutes )>(block.timestamp), "delai depasse");

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
   
   // obtenir les résultats
   
    function resultats (uint _id) public view returns (string memory, uint, uint, uint){
        
        if ((proposition[_id].forVotes > proposition[_id].againstVotes) && (proposition[_id].forVotes > proposition[_id].blankVotes)){
            return ("le Oui l'emporte",proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes) ;
        }
        else if ((proposition[_id].forVotes < proposition[_id].againstVotes) && (proposition[_id].forVotes > proposition[_id].blankVotes)){
            return ("le Non l'emporte", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
        }
        else if ((proposition[_id].forVotes < proposition[_id].againstVotes) && (proposition[_id].forVotes < proposition[_id].blankVotes)){
            return ("le Blanc l'emporte", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
        }
        else {return ("le vote n'est pas décisif", proposition[_id].forVotes, proposition[_id].againstVotes, proposition[_id].blankVotes);
            
        }
    } 

}