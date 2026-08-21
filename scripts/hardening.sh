#!/usr/bin/env bash
set -euo pipefail

SCAP_PROFILE="xccdf_org.ssgproject.content_profile_cis_server_l1"
RESULTS_ARF="/var/tmp/openscap-results.arf"
REPORT_HTML="/var/tmp/openscap-report.html"

SCAP_DATASTREAM=""
for candidate in \
  /usr/share/xml/scap/ssg/content/ssg-rocky9-ds.xml \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
do
  if [[ -f "${candidate}" ]]; then
    SCAP_DATASTREAM="${candidate}"
    break
  fi
done

if [[ -z "${SCAP_DATASTREAM}" ]]; then
  echo "OpenSCAP datastream not found. Checked: ssg-rocky9-ds.xml, ssg-rhel9-ds.xml"
  exit 1
fi

oscap xccdf eval \
  --profile "${SCAP_PROFILE}" \
  --results-arf "${RESULTS_ARF}" \
  --report "${REPORT_HTML}" \
  --remediate \
  "${SCAP_DATASTREAM}"

# Re-run after remediation and fail if still non-compliant.
oscap xccdf eval \
  --profile "${SCAP_PROFILE}" \
  --results-arf "${RESULTS_ARF}" \
  --report "${REPORT_HTML}" \
  "${SCAP_DATASTREAM}"
