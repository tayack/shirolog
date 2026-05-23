import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import os

# ---------------------------------------------------------
# 設定: Firebase コンソールから取得した秘密鍵のパス
# ---------------------------------------------------------
SERVICE_ACCOUNT_KEY = 'shirolog_service_account.json'

def initialize_firebase():
    """Firebaseの初期化を行い、Firestoreクライアントを返す"""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        key_path = os.path.join(script_dir, SERVICE_ACCOUNT_KEY)

        if not os.path.exists(key_path):
            print(f"エラー: '{key_path}' が見つかりません。")
            return None

        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Firebase初期化エラー: {e}")
        return None

def delete_collection(db, collection_name):
    """指定されたコレクション内のすべてのドキュメントを削除する"""
    print(f"'{collection_name}' コレクションを削除中...")
    try:
        collection_ref = db.collection(collection_name)
        docs = collection_ref.list_documents()
        deleted = 0
        for doc in docs:
            doc.delete()
            deleted += 1
        print(f"'{collection_name}' から {deleted} 件の古いデータを削除しました。")
    except Exception as e:
        print(f"'{collection_name}' の削除中にエラーが発生しました: {e}")

def import_missions(db, csv_path):
    """missions.csvを読み込み、master_missionsコレクションに登録する"""
    if not os.path.exists(csv_path):
        print(f"エラー: {csv_path} が見つかりません。")
        return

    # pandasで読み込み、欠損値を空文字に置き換える
    df = pd.read_csv(csv_path, encoding='utf-8').fillna('')
    print(f"'{csv_path}' から {len(df)} 件のミッションデータをインポート中...")

    batch = db.batch()

    def clean_val(val):
        v = str(val).strip()
        return "" if v.lower() == 'nan' else v

    for _, row in df.iterrows():
        doc_ref = db.collection('master_missions').document(str(row['m_id']))

        # カンマ区切りの文字列をリストに変換
        target_ids = [s.strip() for s in str(row['target_ids']).split(',') if s.strip()]

        sort_order = int(row['sort_order']) if 'sort_order' in df.columns and pd.notna(row['sort_order']) else 0

        data = {
            'm_id': clean_val(row['m_id']),
            'title_ja': clean_val(row['title_ja']),
            'title_en': clean_val(row['title_en']),
            'title_zh': clean_val(row['title_zh']),
            'title_ko': clean_val(row['title_ko']),
            'description_ja': clean_val(row['description_ja']),
            'description_en': clean_val(row['description_en']),
            'description_zh': clean_val(row['description_zh']),
            'description_ko': clean_val(row['description_ko']),
            'targetSpotIds': target_ids,
            'sort_order': sort_order,
        }
        batch.set(doc_ref, data)

    batch.commit()
    print("master_missions のインポートが完了しました。")

if __name__ == "__main__":
    db = initialize_firebase()
    if db:
        print("=== Firestore ミッションマスタデータ構築 ===")
        delete_collection(db, 'master_missions')

        script_dir = os.path.dirname(os.path.abspath(__file__))
        import_missions(db, os.path.join(script_dir, 'missions.csv'))

        print("=== 処理が完了しました ===")
