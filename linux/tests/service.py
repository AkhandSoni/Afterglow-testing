import json, os, subprocess
binary=os.environ.get('AFTERGLOW_LYRICS_BINARY','.build/debug/afterglow-lyrics')
def request(value):
    result=subprocess.run([binary],input=json.dumps(value),text=True,capture_output=True,timeout=10,check=True)
    return json.loads(result.stdout)
assert request({'command':'demo'})['document']['lines'][0]['words']
lrc=request({'command':'import','fileExtension':'lrc','text':'[offset:500]\n[00:02.50]सितारे ✨\n[00:05.00]Returns'})
assert lrc['document']['lines'][0]['time']==2 and lrc['document']['lines'][0]['text']=='सितारे ✨'
enhanced=request({'command':'import','fileExtension':'lrc','text':'[00:02.00]<00:02.00>Light <00:03.00>returns<00:04.00>'})
assert len(enhanced['document']['lines'][0]['words'])==2
yaml=request({'command':'import','fileExtension':'yaml','text':"lines:\n- text: Light\n  start_ms: 1000\n  end_ms: 2000\n"})
assert yaml['document']['lines'][0]['time']==1
assert request({'command':'import','fileExtension':'txt','text':'Untimed lyrics'})['document']['plainText']=='Untimed lyrics'
assert request({'command':'import','fileExtension':'lrc','text':'Invalid file'})['error']
assert request({'command':'unknown'})['error']
assert request({'command':'resolve','track':{'title':'bad','artist':'a','album':'','duration':-1}})['error']
print('PASS shared Swift service: demo, LRC, enhanced LRC, YAML, plain text, invalid input and requests')
