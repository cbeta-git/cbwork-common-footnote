##################################################################################
# �հɴ��J�{�����Ѽ�
##################################################################################

# �o�@�ӬO�U��, ���ҥH�Ĥ@�U�ӻ���, �z�פW�u���o�@�ӭn�g�`�� (���U�N�n��)

$vol = "T01";


#�o�O xml ���ӷ��ؿ�

$xml_dir = "c:/cbwork/xml/"; 			# xml �ӷ��ؿ�

#�o�O��J xml �ɪ��ؿ�, �b�o�@�ӨҤl���|���� c:/xmlout/T01/ ���ؿ�, 
#���L c:/xmlout/ �n�ۦ������, ���M�|�����~.

$out_dir = "c:/xmlout/${vol}/"; 	 	# ��X�ؿ�

#�o�O�հɱ�����, �o�@�Ҫ��հɱ��جO T01xml.txt
#�o�O�� checknote.pl ���ͪ� xml �հɱ���, ���O²�檩����

$xml_note = "${vol}xml.txt";			# �հɱ���

#�o�O���~���i��X��, ���ҬO T01_error.txt

$err_out = "${vol}_error.txt";		# ���~��X��