# Digital-Envelope

Digital Envelope can be defined as an electronic data container which can be used to provide confidentiality, integrity, and authentication. To achieve this goal symmetric and asymmetric cryptography is used along with hashing algorithms.

### Pre-requiste:

OpenSSL version 3 should be installed. 
**Note: The script was tested on OpenSSL 3.0.6**

### How to use:

**To encrypt:***
./crypto.sh -e <receiver1_public_key.pub> <receiver2_public_key.pub> <receiver3_public_key.pub> <sender_private_key.priv> <plaintext_file> <encrypted_filename>

**To decrypt:**
./crypto.sh -d <recierver#_private_key.priv> <sender_public_key.pub> <encrypted_filename> <decrypted_filename>

### Assumptions:
There is a group of 4 members (1 sender and 3 receivers) and all group members have their own RSA private-public key pairs. Also they’ve shared their public key with each other previously. The script outputs just one file on encryption (zip file).

**Note: This is just a POC and only encrypts a short plaintext message.**

