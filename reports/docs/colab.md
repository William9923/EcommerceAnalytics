## How to pip freeze colab
---
Data science notebook configuration snippet:
```python
!pip freeze --local > requirements.txt
```

## How to install requirements.txt to colab
---
1. Upload the requirements.txt
2. Use this snippet
```python
!pip install --upgrade --force-reinstall `cat requirements.txt`
```



