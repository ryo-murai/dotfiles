#!/bin/sh

CERT_FILE="$1"
TARGET_JDK_HOME="${2-:${JAVA_HOME}}"

# if no cert file provided, exit
if [ -z "$CERT_FILE" ]; then
  echo "USAGE: setup_jdk_zscaler_cacert.sh <path-to-zscaler-certificate-file> [<path-to-jdk-home>]"
  echo "No certificate file provided. Exiting."
  exit 1
fi

# if no target JDK home provided, exit
if [ -z "$TARGET_JDK_HOME" ]; then
  echo "USAGE: setup_jdk_zscaler_cacert.sh <path-to-zscaler-certificate-file> [<path-to-jdk-home>]"
  echo "No target JDK home provided. Exiting."
  exit 1
fi

# Note: If the certificate file extension is not DER or der, convert it to DER format first using:
if [ "${CERT_FILE##*.}" != "der" ] && [ "${CERT_FILE##*.}" != "DER" ]; then
  echo "Converting certificate to DER format..."
  DER_CERT_FILE="${CERT_FILE%.*}.der"
  openssl x509 -in "$CERT_FILE" -inform pem -out "$DER_CERT_FILE" -outform der
  CERT_FILE="$DER_CERT_FILE"
fi

# import the certificate into the JDK cacerts keystore
$TARGET_JDK_HOME/bin/keytool -import -trustcacerts -alias zscalerrootca -file "$CERT_FILE" -keystore $TARGET_JDK_HOME/lib/security/cacerts -storepass changeit -noprompt


$TARGET_JDK_HOME/bin/keytool -list -v -keystore $TARGET_JDK_HOME/lib/security/cacerts -storepass changeit | grep zscalerrootca