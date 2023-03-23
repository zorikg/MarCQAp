DATA_DIR=$1
PREDICTIONS_DIR=$2

echo "DATA_DIR: $1";
echo "PREDICTIONS_DIR: $2";


TMP_DIR="${PREDICTIONS_DIR}/tmp"

mkdir $TMP_DIR

echo ''
echo "Downloading quac/scorer.py"
echo ''
curl -o "${TMP_DIR}/scorer.py" https://s3.amazonaws.com/my89public/quac/scorer.py
echo ''
echo ''

echo "Downloading quac/val_v0.2.json"
echo ''
curl -o "${TMP_DIR}/val_v0.2.json" https://s3.amazonaws.com/my89public/quac/val_v0.2.json
echo ''
echo ''

echo "Evaluating..."
echo ''

name_percent=(
  "large 100%"
  "base 100%"
  "base_0.2 20%"
  "base_0.1 10%"
  "base_0.05 5%"
  "base_0.01 1%"
)


DATA="${TMP_DIR}/val_v0.2.json"
for entry in "${name_percent[@]}"
do
  set -- $entry
  NAME=$1
  PERCENT=$2

  PREDS="${PREDICTIONS_DIR}/marcqap_${NAME}_quac.json"

  SIZE=$NAME

  python "${TMP_DIR}/scorer.py" \
    --val_file="${DATA}" \
    --model_output="${PREDS}" \
    | grep "Overall F1: " | sed "s/Overall F1/MarCQAp ${SIZE} QuAC (${PERCENT})/"

done

data_domain=(
  "coqa children_stories"
  "coqa literature"
  "coqa mid-high_school"
  "coqa news"
  "coqa wikipedia"
  "doqa cooking"
  "doqa travel"
  "doqa movies"
)

for entry in "${data_domain[@]}"
do
  set -- $entry
  DATASET=$1
  DOMAIN=$2

  PREDS="${PREDICTIONS_DIR}/marcqap_base_1.0_${DATASET}-${DOMAIN}.json"
  DATA="${DATA_DIR}/${DATASET}_dev_${DOMAIN}.json"
  python "${TMP_DIR}/scorer.py" --val_file="${DATA}" --model_output="${PREDS}" \
     | grep "Overall F1: " | sed "s/Overall F1/MarCQAp base ${DATASET} ${DOMAIN}/"

done


python "${TMP_DIR}/scorer.py" \
  --val_file="${DATA_DIR}/quac_NH.json" \
  --model_output="${PREDICTIONS_DIR}/marcqap_base_1.0_quac-nh.json" \
   | grep "Overall F1: " | sed "s/Overall F1/MarCQAp Base QuAC-NH/"


rm -r $TMP_DIR
echo ''
