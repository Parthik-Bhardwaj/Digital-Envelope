#!/bin/bash


function encryption {

  # Session key / symmetric key generated
  if openssl rand 192 > sessionKey 2>/dev/null ; then
    echo "Session Key Generated."
  else  
    >&2 echo "ERROR bhardwaj.p - unable to generate session key."
    exit 1
  fi

  # message encrypted with session key
  if openssl enc -in ${6} -out message.enc -e -aes-256-cbc -pbkdf2 -k sessionKey 2>/dev/null ; then
    echo "Message file encrypted with session key."
  else
    >&2 echo "ERROR bhardwaj.p - unable to encrypt the file." 
    exit 1   
  fi

  # encrypt symmetric key with receiver1 public key
  if openssl pkeyutl -encrypt -pubin -inkey ${2} -in sessionKey -out "sessionKey_1.enc" 2>/dev/null ; then
    echo "Session Key encrypted with ${2}"
  else 
    >&2 echo "ERROR bhardwaj.p - unable to encrypt session key with ${2}. Aborting the program."
    exit 1
  fi      

  # encrypt symmetric key with receiver2 public key
  if openssl pkeyutl -encrypt -pubin -inkey ${3} -in sessionKey -out "sessionKey_2.enc" 2>/dev/null ; then
    echo "Session Key encrypted with ${3}"
  else 
    >&2 echo "ERROR bhardwaj.p - unable to encrypt session key with ${3}. Aborting the program."
    exit 1
  fi  

  # encrypt symmetric key with receiver3 public key
  if openssl pkeyutl -encrypt -pubin -inkey ${4} -in sessionKey -out "sessionKey_3.enc" 2>/dev/null ; then
      echo "Session Key encrypted with ${4}"
  else 
    >&2 echo "ERROR bhardwaj.p - unable to encrypt session key with ${4}. Aborting the program."
    exit 1
  fi  

  # hashing and signing the encrypted file
  if openssl dgst -sha3-512 -sign ${5} -out message.signed message.enc 2>/dev/null ; then
    echo "Signed the encrypted message with ${5}"
  else
    >&2 echo "ERROR bhardwaj.p - unable to sign the encrypted message with ${5}. Aborting the program."
  fi


  if zip "${7}" message.enc message.signed sessionKey_1.enc sessionKey_2.enc sessionKey_3.enc 1>/dev/null 2>/dev/null ; then
    echo "Encryption process complete!"

    if rm message.enc message.signed sessionKey_1.enc sessionKey_2.enc sessionKey_3.enc sessionKey 2>/dev/null ; then
      echo "Clean up complete!"
    else
      >&2 echo "ERROR bhardwaj.p - unexpected error occurred while removing temporary files."
    fi  
  else 
      >&2 echo "ERROR bhardwaj.p - unable to create a package."
  fi
    
}

function decryption {

  # unzip the package  
  if unzip ${4} 1>/dev/null ; then
    echo "unzipping the file."
  else
    >&2 echo "ERROR bhardwaj.p - error occurred while un-packing the package."
  fi    

  # verify encrypted message signature with signed message.
  if openssl dgst -sha3-512 -verify ${3} -signature message.signed message.enc 1>/dev/null 2>/dev/null ; then
    echo "Verification complete. Decrypting message."
  else
    >&2 echo "ERROR bhardwaj.p - Verification failed. Aborting the program."
  fi

  # Nested if-else to decrypt session key.
  if openssl pkeyutl -decrypt -inkey ${2} -in sessionKey_1.enc -out sessionKey 2>/dev/null ; then
    echo "Session Key decrypted."
  else
    if openssl pkeyutl -decrypt -inkey ${2} -in sessionKey_2.enc -out sessionKey 2>/dev/null ; then
      echo "Session Key decrypted."
    else
      if openssl pkeyutl -decrypt -inkey ${2} -in sessionKey_3.enc -out sessionKey 2>/dev/null ; then
        echo "Session Key decrypted."
      else
        >&2 echo "ERROR bhardwaj.p - session key could not be decrypted. Please check if correct private key was provided."
        exit 1
      fi
    fi  
  fi    

  # decrypt the message.
  if openssl enc -in message.enc -out ${5} -d -aes-256-cbc -pbkdf2 -k sessionKey 2>/dev/null ; then
    echo "Message decrypted successfully!"
  else
    >&2 echo "ERROR bhardwaj.p - unable to decrypt message. Aborting the program."
    exit 1
  fi

  # Perform clean-up
  if rm session* message.enc message.signed 2>/dev/null ; then
    echo "Clean up complete!"
  else
    >&2 echo "ERROR bhardwaj.p - couldn't complete the clean-up process."
  fi     
}


# check for first arguement and perform encryption/decryption based on that
case "${1}" in
    -e)
      # check for arguement number
      if [ "$#" -eq "7" ] ; then
        encryption ${@}
      else
        >&2 echo "ERROR bhardwaj.p - check if all aeguements are provided. Refer ./crypto.sh -e receiver1.pub receiver2.pub receiver3.pub sender.priv <plaintext_file> <encrypted_file>"
        exit 1
      fi    
      ;;
    -d)
      # check for arguemnt number
      if [ "$#" -eq "5" ] ; then
        decryption ${@}
      else
        >&2 echo "ERROR bhardwaj.p - check if all aeguements are provided. Refer ./crypto.sh -d recierver<#>.priv sender.pub <encrypted_file> <decrypted_file>"
        exit 1
      fi
      ;;
    *)
      >&2 echo "ERROR bhardwaj.p - unsupported mode. Please use '-e' for encryption and '-d' for decryption."
      exit 1
      ;;
esac
