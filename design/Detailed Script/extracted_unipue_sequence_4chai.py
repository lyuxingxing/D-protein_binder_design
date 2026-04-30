from pathlib import Path

# 定义包含fasta文件路径的txt文件
fasta_list_file = Path("15_design2_fasta.txt")  # txt文件，每行是一个fasta文件路径

output_folder = Path("formatted_fasta")
output_folder.mkdir(parents=True, exist_ok=True)

# 转换字典
conversion = {
    'A': 'DAL', 'C': 'DCY', 'D': 'DAS', 'E': 'DGL', 'G': 'GLY', 'P': 'DPR', 'K': 'DLY',
    'T': 'DTH', 'S': 'DSN', 'N': 'DSG', 'Q': 'DGN', 'H': 'DHI', 'W': 'DTR', 'Y': 'DTY',
    'I': 'DIL', 'L': 'DLE', 'F': 'DPN', 'M': 'MED', 'R': 'DAR', 'V': 'DVA'
}

# 读取txt文件中的fasta文件路径
with fasta_list_file.open('r') as file:
    input_files = [Path(line.strip()) for line in file if line.strip()]

# 创建一个集合来存储已处理过的A链序列，以去除重复
processed_sequences = set()

# 处理每个输入文件
for input_file in input_files:
    with input_file.open('r') as f:
        lines = f.readlines()

    for index, line in enumerate(lines):
        if line.startswith('>'):
            # 提取命名信息
            header = line.split(',')[0].replace('>', '')
            fasta_name = f"{header}_{index + 1}.fasta"
            output_path = output_folder / fasta_name

            # 分割链
            sequence = lines[index + 1].strip()
            chain_a, chain_b = sequence.split(":")

            # 替换A链中的氨基酸并添加括号
            chain_a_converted = ''.join(f'({conversion.get(res, res)})' for res in chain_a)

            # 检查是否已经处理过该A链序列
            if chain_a_converted not in processed_sequences:
                processed_sequences.add(chain_a_converted)

                # 写入新的FASTA格式
                with output_path.open('w') as out_f:
                    out_f.write(f">protein|A\n{chain_a_converted}\n")
                    out_f.write(f">protein|B\n{chain_b}\n")

print("所有FASTA文件已成功格式化和保存！")
